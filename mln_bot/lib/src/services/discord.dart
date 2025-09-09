import "package:mln_bot/data.dart";
import "package:mln_bot/services.dart";
import "package:mln_bot/commands.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_bot/src/services/discord_utils.dart";
import "package:mln_shared/mln_shared.dart" hide User;

import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

typedef MlnClientCallback = Future<void> Function(MlnClient client);
class DiscordClient extends Service {
  final commandsPlugin = CommandsPlugin(
    prefix: mentionOr((_) => "!"),
    options: const CommandsOptions(
      defaultResponseLevel: ResponseLevel.hint,
      type: CommandType.slashOnly,
      // logErrors: false,
    ),
  );

  static final subscribeCommand = ChatGroup(
    "subscribe",
    "Get notified in Discord about MLN events",
    children: [
      subscribeMailCommand,
    ],
  );

  static final unsubscribeCommand = ChatGroup(
    "unsubscribe",
    "Stop Discord notifications for MLN events",
    children: [
      unsubscribeMailCommand,
    ],
  );

  static List<CommandRegisterable> commands = [
    befriendCommand,
    randomUserCommand,
    userQuery,
    loginCommand,
    logoutCommand,
    subscribeCommand,
    unsubscribeCommand,
    itemQuery,
    itemQueryPublic,
    unfriendCommand,
    blockCommand,
    unblockCommand,
  ];

  late final NyxxGateway _client;

  @override
  Future<void> init() async {
    commands.forEach(commandsPlugin.addCommand);
    _client = await Nyxx.connectGateway(
      discordApiToken, // Replace this with your bot's token
      GatewayIntents.allUnprivileged,
      options: GatewayClientOptions(
        plugins: [logging, cliIntegration, commandsPlugin, ignoreExceptions],
      ),
    );
    _client.setStatus();
    final botUser = await _client.users.fetchCurrentUser();
    _client.onMessageCreate.listen((event) async {
      if (event.mentions.contains(botUser)) {
        await event.message.channel.sendMessage(MessageBuilder(
          content: "I don't get it.\n\nSorry, us Discord bots only respond to / commands",
        ));
      }
    });
    _client.onMessageReactionAdd.listen(_handleReactions);
    _client.onMessageComponentInteraction.listen(_handleInteractions2);
    _client.onApplicationCommandInteraction.listen(_handleCommand);
  }

  Future<void> sendMessage(Snowflake user, MessageBuilder message) async {
    final channel = await _client.users.createDm(user);
    await channel.sendMessage(message);
  }

  Future<void> _handleInteractions2(InteractionCreateEvent<MessageComponentInteraction> event) async {
   final data = event.interaction.data;
    final pattern = data.customId.splitFirst("_");
    if (pattern == null) return;
    final (type, arg) = pattern;
    switch (type) {
      case "message-reply": await _handleReply(event, data, int.parse(arg));
      case "message-read": await _handleMarkAsRead(event, int.parse(arg));
      case "message-delete": await _handleMessageDelete(event, int.parse(arg));
      case "user": await _handleBefriend(event, data, arg);
      case "item": await _handleItems(event, data, isPublic: arg == "true");
      case "unsubscribe-mail": await _handleUnsubscribeMail(event, data);
    }
  }

  void _handleCommand(InteractionCreateEvent<ApplicationCommandInteraction> event) {
    final data = event.interaction.data;
    final commandName = data.name;
    services.cache.updateStats(commandName).ignore();
  }

  Future<void> _handleInteraction(
    InteractionCreateEvent event,
    MlnClientCallback callback,
  ) async {
    final client = event.mlnClient;
    if (client == null) {
      await _client.replyToString(event, "You're not signed in");
    } else {
      await callback(client);
    }
  }

  Future<void> _handleReply(
    InteractionCreateEvent event,
    MessageComponentInteractionData data,
    int messageID,
  ) => _handleInteraction(event, (client) async {
    final replyID = int.parse(data.values!.first);
    await _client.followUp(
      event,
      func: () => client.reply(messageID, replyID),
      followUp: MessageReply("Message sent"),
    );
  });

  Future<void> _handleBefriend(
    InteractionCreateEvent event,
    MessageComponentInteractionData data,
    String username,
  ) => _handleInteraction(event, (client) async {
    await _client.followUp(
      event,
      func: () => client.befriend(username),
      followUp: MessageReply("Sent a friend request to $username"),
    );
  });

  Future<void> _handleItems(
    InteractionCreateEvent event,
    MessageComponentInteractionData data,
    {required bool isPublic}
  ) async {
    final itemName = data.values!.first;
    final item = services.editorial.searchItems(itemName).first;
    final builder = await item.describe(isPublic: isPublic);
    await _client.replyTo(event, builder);
  }

  Future<void> _handleUnsubscribeMail(
    InteractionCreateEvent event,
    MessageComponentInteractionData data,
  ) => _handleInteraction(event, (client) async {
    final webhookID = services.cache.mailWebhooks[client.accessToken];
    if (webhookID == null) return _client.replyToString(event, "You were not subscribed");
    await _client.followUp(
      event,
      func: () => deleteMailWebhook(client, webhookID),
      followUp: MessageReply("Unsubscribed"),
    );
  });

  Future<void> _handleMarkAsRead(
    InteractionCreateEvent event,
    int messageID,
  ) => _handleInteraction(event, (client) async {
    await _client.followUp(
      event,
      func: () => client.markAsRead(messageID),
      followUp: MessageReaction.thumbsUp(),
    );
  });

  Future<void> _handleMessageDelete(
    InteractionCreateEvent event,
    int messageID,
  ) => _handleInteraction(event, (client) async {
    await _client.followUp(
      event,
      func: () => client.deleteMessage(messageID),
      followUp: MessageDelete(),
    );
  });

  Future<void> _handleReactions(MessageReactionAddEvent event) async {
    final emoji = event.emoji;
    final isX = emoji.name == "❌";
    if (!isX) return;

    final channel = await event.message.channel.get();
    final isMod = await event.hasRole("Moderator");
    final isDm = channel.type == ChannelType.dm;
    final isFromBot = event.messageAuthorId == _client.user.id;

    final shouldDelete = isFromBot && (isMod || isDm);
    if (shouldDelete) {
      await event.message.delete();
    } else {
      await event.message.deleteReaction(ReactionBuilder.fromEmoji(emoji));
    }
  }
}
