import "utils.dart";

final blockCommand = ChatCommand("block", "Block a friend", _block);

Future<void> _block(
  ChatContext context,
  @Description("The MLN or Discord user to block")
  String username,
) => authedCommand(context,
  (client) => userCommand(context, username,
    (user) => context.handle<bool>(
      func: () => client.block(user),
      onSuccess: (_) => context.respondText("$user is no longer your friend"),
    )
  )
);
