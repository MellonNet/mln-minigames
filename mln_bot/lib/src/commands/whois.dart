import "package:mln_bot/clients.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "utils.dart";

final userQuery = ChatCommand(
  "who-is",
  "Gets information about a user",
  userQueryAction,
);

Future<void> userQueryAction(ChatContext context, [String? username]) async {
  final client = await context.getClient();
  if (client == null) return;
  if (username == null) {
    await context.respondText("You gotta tell me who you want to know about");
    return;
  }

  const prefix = "Sure! Sure! Here's what I know about";
  username = await client.checkUsername(username);
  if (username == null) {
    return context.respondText("That user has not linked their MLN account");
  }
  final description = await client.getUser(username)
    .handle((user) => user.describe(prefix), "User not found");
  await context.respondText(description);
}
