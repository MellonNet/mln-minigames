import "package:nyxx/nyxx.dart" hide Webhook, WebhookType;

import "package:mln_shared/mln_shared.dart";
import "package:mln_bot/data.dart";
import "package:mln_bot/commands.dart";
import "package:mln_bot/services.dart";

import "discord_utils.dart";

typedef MlnClientCallback = Future<void> Function(MlnClient client);

mixin DiscordInteractions {
  NyxxGateway get discordClient;

  Future<void> handleMessageInteractions(
    InteractionCreateEvent<MessageComponentInteraction> event,
  ) async {
   final data = event.interaction.data;
    final pattern = data.customId.splitFirst("_");
    if (pattern == null) return;
    final (type, arg) = pattern;
    switch (type) {
      case "message-reply": await _handleReply(event, data, int.parse(arg));
      case "message-read": await _handleMarkAsRead(event, int.parse(arg));
      case "message-read-hidden": await _handleMarkAsRead(event, int.parse(arg), isHidden: true);
      case "message-delete": await _handleMessageDelete(event, int.parse(arg));
      case "message-delete-hidden": await _handleMessageDelete(event, int.parse(arg), isHidden: true);
      case "friend-add": await _handleFriend(event, accept: true, arg);
      case "friend-add-edit": await _handleFriend(event, accept: true, replace: true, arg);
      case "friend-delete": await _handleFriend(event, accept: false, arg);
      case "item": await _handleItems(event, data, isPublic: arg == "true");
      case "unsubscribe": await _handleUnsubscribe(event, WebhookType.values.byName(arg));
    }
  }

  Future<void> _handleInteraction(
    InteractionCreateEvent<MessageComponentInteraction> event,
    MlnClientCallback callback,
  ) async {
    final client = event.mlnClient;
    if (client == null) {
      final userID = event.discordUser?.id;
      if (userID == null) {
        await discordClient.replyToString(event, "You're not signed in");
      } else {
        final sessionID = services.cache.discordToMln(userID);
        final builder = buildLogin(sessionID);
        await discordClient.replyTo(event, builder);
      }
    } else {
      await callback(client);
    }
  }

  Future<void> _handleReply(
    InteractionCreateEvent<MessageComponentInteraction> event,
    MessageComponentInteractionData data,
    int messageID,
  ) => _handleInteraction(event, (client) async {
    final replyID = int.parse(data.values!.first);
    await discordClient.followUp(
      event,
      func: () => client.reply(messageID, replyID),
      followUp: (_) => MessageReply("Message sent"),
    );
  });

  Future<void> _handleFriend(
    InteractionCreateEvent<MessageComponentInteraction> event,
    String username,
    {required bool accept, bool replace = false}
  ) => _handleInteraction(event, (client) async {
    if (accept) {
      await discordClient.followUp(
        event,
        func: () => client.befriend(username),
        followUp: (friendship) => MessageReply(friendship.action!, replace: replace),
      );
    } else {
      await discordClient.followUp(
        event,
        func: () => client.unfriend(username),
        followUp: (_) => MessageDelete(),
      );
    }
  });


  Future<void> _handleItems(
    InteractionCreateEvent<MessageComponentInteraction> event,
    MessageComponentInteractionData data,
    {required bool isPublic}
  ) async {
    final itemName = data.values!.first;
    final item = services.editorial.searchItems(itemName).first;
    final builder = await item.describe(isPublic: isPublic);
    await discordClient.replyTo(event, builder);
  }

  Future<void> _handleUnsubscribe(
    InteractionCreateEvent<MessageComponentInteraction> event,
    WebhookType type,
  ) => _handleInteraction(event, (client) async {
    final webhook = services.cache.getWebhook(client.accessToken, type);
    if (webhook == null) return discordClient.replyToString(event, "You were not subscribed");
    await discordClient.followUp(
      event,
      func: () => deleteWebhook(client, webhook),
      followUp: (_) => MessageReply("Unsubscribed"),
    );
  });

  Future<void> _handleMarkAsRead(
    InteractionCreateEvent<MessageComponentInteraction> event,
    int messageID,
    {bool isHidden = false}
  ) => _handleInteraction(event, (client) async {
    await discordClient.followUp(
      event,
      func: () => client.markAsRead(messageID),
      followUp: (_) => isHidden ? MessageReply("Marked as read") : MessageReaction.thumbsUp(),
    );
  });

  Future<void> _handleMessageDelete(
    InteractionCreateEvent<MessageComponentInteraction> event,
    int messageID,
    {bool isHidden = false}
  ) => _handleInteraction(event, (client) async {
    await discordClient.followUp(
      event,
      func: () => client.deleteMessage(messageID),
      followUp: (_) => isHidden ? MessageReply("Deleted message") : MessageDelete(),
    );
  });
}
