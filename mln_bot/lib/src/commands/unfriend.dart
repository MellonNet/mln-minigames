import "utils.dart";

final unfriendCommand = ChatCommand("unfriend", "Delete a friend (or rescind friend request)", _unfriend);

Future<void> _unfriend(
  ChatContext context,
  @Description("The MLN or Discord user to unfriend")
  String username,
) => authedCommand(context,
  (client) => userCommand(context, username,
    (user) => context.handle<bool>(
      func: () => client.unfriend(user),
      onSuccess: (_) => context.respondText("$user is no longer your friend"),
    ),
  ),
);
