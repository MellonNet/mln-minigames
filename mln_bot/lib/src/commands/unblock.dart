import "utils.dart";

final unblockCommand = ChatCommand("unblock", "Unblock a friend", _unblock);

Future<void> _unblock(
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
    func: () => client.unblock(username!),
    onSuccess: (_) => context.respondText("$username is no longer your friend"),
  );
}
