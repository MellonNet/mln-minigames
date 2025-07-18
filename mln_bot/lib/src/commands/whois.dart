import "package:mln_bot/clients.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "utils.dart";

final userQuery = ChatCommand(
  "whois",
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
  final description = await client.getUser(username).handle((user) => user.describe());
  await context.respondText(description);
}
