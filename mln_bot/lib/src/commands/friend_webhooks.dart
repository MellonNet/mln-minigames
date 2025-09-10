import "package:mln_bot/src/commands/webhook_utils.dart";

import "utils.dart";

final subscribeFriendCommand = ChatCommand(
  "friends",
  "Get notified of new friend requests",
  _subscribeFriends,
);

Future<void> _subscribeFriends(ChatContext context) =>
  subscribeWebhook(context, WebhookType.friendships);

final unsubscribeFriendCommand = ChatCommand(
  "friends",
  "Stop getting notified about friends",
  _unsubscribeFriends,
);

Future<void> _unsubscribeFriends(ChatContext context) =>
  unsubscribeWebhook(context, WebhookType.friendships);
