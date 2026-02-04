import "utils.dart";

final subscribeFriendCommand = ChatCommand(
  "friends",
  "Get notified of new friend requests",
  id("subscribe_friends", _subscribeFriends),
);

Future<void> _subscribeFriends(ChatContext context) => authedCommand(context,
  (client) async => context.respond(
    await subscribeWebhook(client, WebhookType.friendships),
  ),
);

final unsubscribeFriendCommand = ChatCommand(
  "friends",
  "Stop getting notified about friends",
  id("unsubscribe_friends", _unsubscribeFriends),
);

Future<void> _unsubscribeFriends(ChatContext context) =>
  unsubscribeWebhook(context, WebhookType.friendships);
