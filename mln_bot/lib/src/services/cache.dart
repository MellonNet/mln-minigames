import "dart:async";
import "dart:convert";
import "dart:io";

import "package:collection/collection.dart";
import "package:mln_bot/services.dart";
import "package:nyxx/nyxx.dart" hide Webhook, WebhookType;

import "package:mln_shared/mln_shared.dart";

class Cache extends Service {
  static final sessionsFile = File("cache/sessions.txt");
  static final snowflakesFile = File("cache/snowflakes.txt");
  static final webhooksFile = File("cache/webhooks.json");
  static final statsFile = File("cache/stats.json");

  Map<SessionID, AccessToken> get sessionToToken =>
    services.server.oauth.sessionToTokens;

  Map<AccessToken, SessionID> get tokenToSession =>
    services.server.oauth.tokenToSession;

  Map<AccessToken, String> get tokensToUsernames =>
    services.server.oauth.accessTokenToUsername;

  final sessionToDiscord = <SessionID, Snowflake>{};
  final webhooks = <Webhook>[];

  Webhook? getWebhook(AccessToken accessToken, WebhookType type) => webhooks
    .firstWhereOrNull((webhook) => webhook.accessToken == accessToken && webhook.type == type);

  Future<void> saveAccessTokens() => _writeCache(sessionsFile, {
    for (final (sessionID, accessToken) in sessionToToken.records)
      sessionID.value: accessToken.value,
  });

  Future<void> saveSnowflakes() => _writeCache(snowflakesFile, {
    for (final (sessionID, snowflake) in sessionToDiscord.records)
      sessionID.value: snowflake.value,
  });

  Future<void> saveWebhooks() => _writeCacheList(webhooksFile, [
    for (final webhook in webhooks)
      webhook.toJson(),
  ]);

  static Future<void> _writeCache(File file, Json data) async {
    final contents = jsonEncode(data);
    await file.create(recursive: true);
    await file.writeAsString(contents);
  }

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
      final data = jsonDecode(contents) as Json;
      for (final (rawSessionID, rawAccessToken) in data.cast<String, String>().records) {
        final sessionID = SessionID(rawSessionID);
        final accessToken = AccessToken(rawAccessToken);
        sessionToToken[sessionID] = accessToken;
        tokenToSession[accessToken] = sessionID;
      }
    }

    if (snowflakesFile.existsSync()) {
      final contents = await snowflakesFile.readAsString();
      final data = jsonDecode(contents) as Json;
      for (final (sessionID, snowflake) in data.cast<String, int>().records) {
        sessionToDiscord[SessionID(sessionID)] = Snowflake(snowflake);
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
    if (!sessionToDiscord.containsKey(sessionID)) {
      sessionToDiscord[sessionID] = snowflake;
      unawaited(saveSnowflakes());
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

  Snowflake? mlnUsernameToDiscord(String username) {
    final accessToken = tokensToUsernames
      .entries.firstWhereOrNull((entry) => entry.value == username)?.key;
    if (accessToken == null) return null;
    final sessionID = tokenToSession[accessToken];
    if (sessionID == null) return null;
    return sessionToDiscord[sessionID];
  }
}
