import "dart:async";
import "dart:convert";
import "dart:io";

import "package:nyxx/nyxx.dart";

import "package:mln_shared/mln_shared.dart";
import "package:mln_bot/data.dart";
import "server.dart";

class Cache {
  static final sessionsFile = File("cache/sessions.txt");
  static final snowflakesFile = File("cache/snowflakes.txt");
  static final mailWebhooksFile = File("cache/webhooks_mail.txt");

  Map<SessionID, AccessToken> get sessionToToken =>
    server.oauth.sessionToTokens;

  Map<AccessToken, SessionID> get tokenToSession =>
    server.oauth.tokenToSession;

  final sessionToDiscord = <SessionID, Snowflake>{};
  final mailWebhooks = <AccessToken, WebhookID>{};

  Future<void> saveAccessTokens() => _writeCache(sessionsFile, {
    for (final (sessionID, accessToken) in sessionToToken.records)
      sessionID.value: accessToken.value,
  });

  Future<void> saveSnowflakes() => _writeCache(snowflakesFile, {
    for (final (sessionID, snowflake) in sessionToDiscord.records)
      sessionID.value: snowflake.value,
  });

  Future<void> saveMailWebhooks() => _writeCache(mailWebhooksFile, {
    for (final (accessToken, webhookID) in mailWebhooks.records)
      accessToken.value: webhookID.id,
  });

  static Future<void> _writeCache(File file, Json data) async {
    final contents = jsonEncode(data);
    await file.writeAsString(contents);
  }

  Future<void> init() async {
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

    if (mailWebhooksFile.existsSync()) {
      final contents = await mailWebhooksFile.readAsString();
      final data = jsonDecode(contents) as Json;
      for (final (accessToken, webhookID) in data.cast<String, int>().records) {
        mailWebhooks[AccessToken(accessToken)] = WebhookID(webhookID);
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
}

final cache = Cache();
