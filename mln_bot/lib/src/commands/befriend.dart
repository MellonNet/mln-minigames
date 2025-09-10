import "utils.dart";

final befriendCommand = ChatCommand("befriend", "Send or accept a friend request", _befriend);

Future<void> _befriend(
  ChatContext context,
  @Description("The MLN or Discord user to befriend")
  String username,
) => authedCommand(context,
  (client) => userCommand(context, username, (user) => context.handle<bool>(
    func: () => client.befriend(user),
    onSuccess: (_) => context.respondText("Sent a friend request to $user"),
  ))
);
