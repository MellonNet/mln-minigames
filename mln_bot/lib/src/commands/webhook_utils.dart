import "utils.dart";

Future<void> subscribeWebhook(ChatContext context, WebhookType type) => authedCommand(context, (client) async {
  var webhook = services.cache.getWebhook(client.accessToken, type);
  if (webhook != null) {
    return context.respondText("You've already subscribed to $type");
  }
  final url = switch (type) {
    WebhookType.friendships => MlnServer.friendsWebhookUrl,
    WebhookType.messages => MlnServer.messagesWebhookUrl,
  };
  webhook = await client.registerWebhook(
    type: type,
    webhookUrl: url,
    webhookSecret: mlnWebhookApiToken,
  ).ignoreApiErrors();
  if (webhook == null) return context.respondText("An error occurred");
  services.cache.webhooks.add(webhook);
  await services.cache.saveWebhooks();
  await context.respondButton(
    "Subscribed! I'll let you know when you get new $type",
    ButtonBuilder.secondary(customId: "unsubscribe_$type", label: "Unsubscribe"),
  );
});

Future<void> unsubscribeWebhook(ChatContext context, WebhookType type) => authedCommand(context, (client) async {
  final webhook = services.cache.getWebhook(client.accessToken, type);
  if (webhook == null) return context.respondText("You were not subscribed to $type");
  await context.handle<void>(
    func: () => deleteWebhook(client, webhook),
    onSuccess: (_) => context.respondText("Unsubscribed"),
  );
});

Future<bool?> deleteWebhook(MlnClient client, Webhook webhook) async {
  final success = await client.deleteWebhook(webhook);
  if (success) {  // only delete locally if it's deleted from the server
    services.cache.webhooks.remove(webhook);
    await services.cache.saveWebhooks();
  }
  return success ? true : null;  // error handlers treat null as failure
}
