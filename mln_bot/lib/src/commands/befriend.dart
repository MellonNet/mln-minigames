import "package:nyxx_commands/nyxx_commands.dart";

import "package:mln_bot/clients.dart";
import "utils.dart";

final befriendCommand = ChatCommand("befriend", "Send or accept a friend request", _befriend);

Future<void> _befriend(ChatContext context, [String? username]) async {
  final client = await context.getClient();
  if (client == null) return;
  if (username == null) {
    await context.respondText("You gotta tell me who to befriend");
    return;
  }
  final description = await client.befriend(username).handle();
  await context.respondText(description);
}
