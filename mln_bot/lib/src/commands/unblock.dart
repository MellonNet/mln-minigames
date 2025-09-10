import "utils.dart";

final unblockCommand = ChatCommand("unblock", "Unblock a friend", _unblock);

Future<void> _unblock(
  ChatContext context,
  @Description("The MLN or Discord user to block")
  String username,
) => authedCommand(context,
  (client) => userCommand(context, username,
    (user) => context.handle<bool>(
      func: () => client.unblock(user),
      onSuccess: (_) => context.respondText("$user is no longer your friend"),
    ),
  ),
);
