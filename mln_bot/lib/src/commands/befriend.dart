import "utils.dart";

final befriendCommand = ChatCommand("befriend", "Send or accept a friend request", _befriend);

Future<void> _befriend(
  ChatContext context, [
  @Description("The MLN or Discord user to befriend")
  String? username,
]) async {
  final client = await context.getClient();
  if (client == null) return;
  if (username == null) {
    await context.respondText("You gotta tell me who to befriend");
    return;
  }
  username = await checkUsername(username);
  if (username == null) {
    return context.respondText("That Discord user has not linked their MLN account");
  }
  await context.handle<bool>(
    func: () => client.befriend(username!),
    onSuccess: (_) => context.respondText("Sent a friend request to $username"),
  );
}
