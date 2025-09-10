import "package:mln_bot/secrets.dart";
import "package:mln_bot/services.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "utils.dart";

final subscribeMailCommand = ChatCommand("mail", "Get notified of new MLN messages", _subscribeMail);

final unsubscribeMailCommand = ChatCommand("mail", "Stop getting notified about MLN messages", _unsubscribeMail);

Future<void> _subscribeMail(ChatContext context) async {
  final client = await context.getClient();
  if (client == null) return;
  var webhookID = services.cache.mailWebhooks[client.accessToken];
  if (webhookID != null) {
    await context.respondText("You've already subscribed to mail notifications.");
    return;
  }
  webhookID = await client.registerMailWebhook(MlnServer.messagesWebhookUrl, mlnWebhookApiToken).ignoreApiErrors();
  if (webhookID == null) {
    await context.respondText("There was an issue. Please contact the developers and try again later");
    return;
  }
  services.cache.mailWebhooks[client.accessToken] = webhookID;
  await services.cache.saveMailWebhooks();
  await context.respondButton(
    "Subscribed! I'll let you know when a new MLN message arrives",
    ButtonBuilder.secondary(customId: "unsubscribe-mail_xxx", label: "Unsubscribe"),
  );
}

Future<void> _unsubscribeMail(ChatContext context) async {
  final client = await context.getClient();
  if (client == null) return;
  final webhookID = services.cache.mailWebhooks[client.accessToken];
  if (webhookID == null) {
    await context.respondText("You were not subscribed to messages");
  } else {
    await context.handle<void>(
      func: () => deleteMailWebhook(client, webhookID),
      onSuccess: (_) => context.respondText("Unsubscribed"),
    );
  }
}

Future<bool?> deleteMailWebhook(MlnClient client, WebhookID webhookID) async {
  final success = await client.deleteWebhook(webhookID);
  if (success) {
    services.cache.mailWebhooks.remove(client.accessToken);
    await services.cache.saveMailWebhooks();
  }
  return success ? true : null;  // error handlers treat null as failure
}
