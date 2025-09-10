import "package:nyxx_commands/nyxx_commands.dart";

import "utils.dart";

final blockCommand = ChatCommand("block", "Block a friend", _block);

Future<void> _block(
  ChatContext context, [
  @Description("The MLN or Discord user to block")
  String? username,
]) async {
  final client = await context.getClient();
  if (client == null) return;
  if (username == null) {
    await context.respondText("Please specify a user");
    return;
  }
  username = await checkUsername(username);
  if (username == null) {
    return context.respondText("That Discord user has not linked their MLN account");
  }
  await context.handle<bool>(
    func: () => client.block(username!),
    onSuccess: (_) => context.respondText("$username is no longer your friend"),
  );
}
