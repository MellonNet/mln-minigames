import "utils.dart";

final unfriendCommand = ChatCommand("unfriend", "Delete a friend (or rescind friend request)", _unfriend);

Future<void> _unfriend(
  ChatContext context, [
  @Description("The MLN or Discord user to unfriend")
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
    func: () => client.unfriend(username!),
    onSuccess: (_) => context.respondText("$username is no longer your friend"),
  );
}
