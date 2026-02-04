import "utils.dart";

final subscribeMailCommand = ChatCommand(
  "messages",
  "Get notified of new messages",
  id("subscribe_mail", _subscribeMail),
);

Future<void> _subscribeMail(ChatContext context) => authedCommand(context,
  (client) async => context.respond(
    await subscribeWebhook(client, WebhookType.messages),
  ),
);

final unsubscribeMailCommand = ChatCommand(
  "messages",
  "Stop getting notified about messages",
  id("unsubscribe_mail", _unsubscribeMail),
);

Future<void> _unsubscribeMail(ChatContext context) =>
  unsubscribeWebhook(context, WebhookType.messages);
