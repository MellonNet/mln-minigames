import "dart:async";
import "dart:convert";
import "dart:io";

import "package:nyxx/nyxx.dart";

import "package:mln_shared/mln_shared.dart";
import "package:mln_bot/data.dart";
import "server.dart";

class Cache {
  static final sessionsFile = File("sessions.txt");
  static final snowflakesFile = File("snowflakes.txt");

  Map<SessionID, AccessToken> get sessionToToken =>
    server.oauth.sessionToTokens;

  final sessionToDiscord = <SessionID, Snowflake>{};
  final sessionToLoginMessage = <SessionID, Message>{};

  Future<void> saveAccessTokens() => _writeCache(sessionsFile, {
    for (final (sessionID, accessToken) in sessionToToken.records)
      sessionID.value: accessToken.value,
  });

  Future<void> saveSnowflakes() => _writeCache(snowflakesFile, {
    for (final (sessionID, snowflake) in sessionToDiscord.records)
      sessionID.value: snowflake.value,
  });

  static Future<void> _writeCache(File file, Json data) async {
    final contents = jsonEncode(data);
    await file.writeAsString(contents);
  }

  Future<void> init() async {
    if (sessionsFile.existsSync()) {
      final contents = await sessionsFile.readAsString();
      final data = jsonDecode(contents) as Json;
      for (final (sessionID, accessToken) in data.cast<String, String>().records) {
        sessionToToken[SessionID(sessionID)] = AccessToken(accessToken);
      }
    }

    if (snowflakesFile.existsSync()) {
      final contents = await snowflakesFile.readAsString();
      final data = jsonDecode(contents) as Json;
      for (final (sessionID, snowflake) in data.cast<String, int>().records) {
        sessionToDiscord[SessionID(sessionID)] = Snowflake(snowflake);
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
