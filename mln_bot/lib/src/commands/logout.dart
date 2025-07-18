import "package:mln_bot/cache.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "utils.dart";

final logoutCommand = ChatCommand("logout", "Removes your MLN data from Discord", _logout);

Future<void> _logout(ChatContext context) async {
  final accessToken = context.accessToken;
  if (accessToken == null) {
    await context.respondText("You were already signed out!");
    return;
  }
  final sessionID = context.sessionID;
  cache.sessionToToken.remove(sessionID);
  await cache.saveAccessTokens();
  cache.sessionToDiscord.remove(sessionID);
  await cache.saveSnowflakes();
  await context.respondText("Done");
}
