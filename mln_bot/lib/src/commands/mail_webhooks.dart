import "package:mln_bot/src/commands/webhook_utils.dart";

import "utils.dart";

final subscribeMailCommand = ChatCommand(
  "messages",
  "Get notified of new messages",
  _subscribeMail,
);

Future<void> _subscribeMail(ChatContext context) =>
  subscribeWebhook(context, WebhookType.messages);

final unsubscribeMailCommand = ChatCommand(
  "messages",
  "Stop getting notified about messages",
  _unsubscribeMail,
);

Future<void> _unsubscribeMail(ChatContext context) =>
  unsubscribeWebhook(context, WebhookType.messages);
