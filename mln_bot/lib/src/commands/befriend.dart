import "utils.dart";

final befriendCommand = ChatCommand("befriend", "Send or accept a friend request", _befriend);

Future<void> _befriend(
  ChatContext context,
  @Description("The MLN or Discord user to befriend")
  String username,
) => authedCommand(context,
  (client) => userCommand(context, username, (user) => context.handle(
    func: () => client.befriend(user),
    onSuccess: (friendship) => context.respondText(friendship.action!),
  )),
);

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
