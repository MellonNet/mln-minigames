import "dart:async";
import "dart:convert";
import "dart:io";

import "package:collection/collection.dart";

import "package:mln_bot/data.dart";
import "package:mln_bot/services.dart";
import "package:mln_shared/mln_shared.dart";

class Cache extends Service {
  static final sessionsFile = File("cache/sessions.json");
  static final webhooksFile = File("cache/webhooks.json");
  static final statsFile = File("cache/stats.json");

  final List<MellonBotSession> sessions = [];
  final webhooks = <Webhook>[];

  // This is needed to preserve Discord identities via a one-way hash.
  // This does not need to be persisted -- the MellonBotSession has it.
  final _sessionIDToDiscord = <SessionID, Snowflake>{};

  final Map<Snowflake, MellonBotSession> sessionsByDiscord = {};
  final Map<String, MellonBotSession> sessionsByMlnUsername = {};
  final Map<AccessToken, MellonBotSession> sessionsByAccessToken = {};

  Future<void> saveSession(SessionID sessionID, AccessToken accessToken) async {
    // When the user presses the login button, their Discord ID is hashed into a SessionID.
    // Their corresponding Discord Snowflake is saved in _sessionIDToDiscord.
    // If the bot is shut down between pressing the login button and signing in, this link
    // will be missing, but in the worst case they just try /login again.
    final discordID = _sessionIDToDiscord[sessionID];
    if (discordID == null) return;

    final mlnUsername = services.server.oauth.accessTokenToUsername[accessToken]!;
    final session = MellonBotSession(discordID: discordID, accessToken: accessToken, sessionID: sessionID, mlnUsername: mlnUsername);
    _cacheSession(session);
    await _saveSessions();
  }

  void _cacheSession(MellonBotSession session) {
    sessionsByDiscord[session.discordID] = session;
    sessionsByMlnUsername[session.mlnUsername] = session;
    sessionsByAccessToken[session.accessToken] = session;
    sessions.add(session);
  }

  Future<void> _saveSessions() => _writeCacheList(sessionsFile, [
    for (final session in sessions)
      session.toJson(),
  ]);

  Webhook? getWebhook(AccessToken accessToken, WebhookType type) => webhooks
    .firstWhereOrNull((webhook) => webhook.accessToken == accessToken && webhook.type == type);

  Future<void> saveWebhooks() => _writeCacheList(webhooksFile, [
    for (final webhook in webhooks)
      webhook.toJson(),
  ]);

  static Future<void> _writeCacheList(File file, List<Json> data) async {
    final contents = jsonEncode(data);
    await file.create(recursive: true);
    await file.writeAsString(contents);
  }

  @override
  Future<void> init() async {
    if (!statsFile.existsSync()) await statsFile.create(recursive: true);
    if (sessionsFile.existsSync()) {
      final contents = await sessionsFile.readAsString();
      final sessionJsons = jsonDecode(contents) as List;
      for (final sessionJson in sessionJsons.cast<Json>()) {
        final session = MellonBotSession.fromJson(sessionJson);
        _cacheSession(session);
      }
    }

    if (webhooksFile.existsSync()) {
      final contents = await webhooksFile.readAsString();
      final data = jsonDecode(contents) as List;
      for (final webhookJson in data.cast<Json>()) {
        webhooks.add(Webhook.fromJson(webhookJson));
      }
    }
  }

  SessionID discordToMln(Snowflake snowflake) {
    final sessionID = SessionID(snowflake.hashCode.toString());
    if (!_sessionIDToDiscord.containsKey(sessionID)) {
      _sessionIDToDiscord[sessionID] = snowflake;
    }
    return sessionID;
  }

  Future<void> updateStats(String commandName) async {
    final contents = await statsFile.readAsString();
    final data = contents.isEmpty ? <String, dynamic>{} : jsonDecode(contents) as Map;
    final count = data[commandName] as int?;
    data[commandName] = (count ?? 0) + 1;
    await statsFile.writeAsString(jsonEncode(data));
  }

  Future<void> removeSession(Snowflake discordID) async {
    final session = sessionsByDiscord[discordID];
    if (session == null) return;
    sessions.remove(session);
    await _saveSessions();
  }
}
