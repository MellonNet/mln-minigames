import "package:nyxx_commands/nyxx_commands.dart";

import "package:mln_bot/server.dart";

import "utils.dart";

final loginCommand = ChatCommand(
  "login",
  "Associates your Discord user with MLN",
  login,
);

Future<void> login(ChatContext context) async {
  final accessToken = context.accessToken;
  if (accessToken != null) {
    await context.respondText("You are already signed in!");
    return;
  }
  final loginUrl = server.oauth.getLoginUri(context.sessionID);
  await context.respondLink("Sign in with My Lego Network", loginUrl);
}
