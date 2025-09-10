import "utils.dart";

final logoutCommand = ChatCommand("logout", "Removes your MLN data from Discord", _logout);

Future<void> _logout(ChatContext context) async {
  final accessToken = context.accessToken;
  if (accessToken == null) {
    await context.respondText("You were already signed out!");
    return;
  }
  final sessionID = context.sessionID;
  services.cache.sessionToToken.remove(sessionID);
  await services.cache.saveAccessTokens();
  services.cache.sessionToDiscord.remove(sessionID);
  await services.cache.saveSnowflakes();
  await context.respondText("Done");
}
