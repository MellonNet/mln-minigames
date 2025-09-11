import "package:mln_shared/clients.dart";
import "package:mln_shared/utils.dart";
import "package:nyxx/nyxx.dart";

class MellonBotSession {
  final Snowflake discordID;
  final AccessToken accessToken;
  final SessionID sessionID;
  final String mlnUsername;

  const MellonBotSession({
    required this.discordID,
    required this.accessToken,
    required this.sessionID,
    required this.mlnUsername,
  });

  MellonBotSession.fromJson(Json json) :
    discordID = Snowflake(json["discord_id"]),
    accessToken = AccessToken(json["access_token"]),
    sessionID = SessionID(json["session_id"]),
    mlnUsername = json["mln_username"];

  Json toJson() => {
    "discord_id": discordID.value,
    "access_token": accessToken.value,
    "session_id": sessionID.value,
    "mln_username": mlnUsername,
  };
}
