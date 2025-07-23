import "package:mln_bot/cache.dart";
import "package:mln_bot/commands.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_shared/mln_shared.dart";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

class DiscordClient {
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
    loginCommand,
    logoutCommand,
    subscribeCommand,
    unsubscribeCommand,
    userQuery,
  ];

  late final NyxxGateway _client;
  Future<void> init() async {
    commands.forEach(commandsPlugin.addCommand);
    _client = await Nyxx.connectGateway(
      discordApiToken, // Replace this with your bot's token
      GatewayIntents.allUnprivileged,
      options: GatewayClientOptions(plugins: [logging, cliIntegration, commandsPlugin]),
    );
    updatePresence();
    final botUser = await _client.users.fetchCurrentUser();
    _client.onMessageCreate.listen((event) async {
      if (event.mentions.contains(botUser)) {
        await event.message.channel.sendMessage(MessageBuilder(
          content: "I don't get it.\n\nSorry, us Discord bots only respond to / commands",
        ));
      }
    });

    _client.onInteractionCreate.listen(_handleInteractions);
  }

  Future<void> _handleInteractions(InteractionCreateEvent event) async {
    final author = event.interaction.user;
    if (author == null) return;
    if (event.interaction.data case final MessageComponentInteractionData data) {
      final messageID = int.parse(data.customId.split("_").last);
      final sessionID = cache.discordToMln(author.id);
      final accessToken = cache.sessionToToken[sessionID];
      if (accessToken == null) {
        await followUp(event.interaction, "You're not signed in");
      } else {
        final client = MlnClient(accessToken, mlnApiToken);
        final replyID = int.parse(data.values!.first);
        final success = await client.reply(messageID, replyID).ignoreApiErrors();
        if (success ?? false) {
          await event.interaction.message!.react(ReactionBuilder(name: "👍", id: null));
          await followUp(event.interaction, "Reply sent");
        } else {
          await followUp(event.interaction, "An error occurred");
        }
      }
    }
  }

  Future<void> followUp(Interaction<dynamic> interaction, String message) async {
    final builder = MessageBuilder(content: message);
    await _client.interactions.createResponse(
      interaction.id,
      interaction.token,
      InteractionResponseBuilder.channelMessage(builder),
      withResponse: true,
    );
  }

  void updatePresence() => _client.updatePresence(
    PresenceBuilder(
      activities: [
        ActivityBuilder(
          name: "My Lego Network",
          type: ActivityType.game,
          state: "Baking an Apple Pie",
          url: Uri.parse("https://mln.lcdruniverse.org"),
        ),
      ],
      status: CurrentUserStatus.online,
      isAfk: false,
      since: DateTime.now(),
    ),
  );

  Future<void> sendMessageText(Snowflake user, String message) async {
    final channel = await _client.users.createDm(user);
    final builder = MessageBuilder(content: message, flags: MessageFlags.ephemeral);
    await channel.sendMessage(builder);
  }

  Future<void> sendMessage(Snowflake user, MessageBuilder message) async {
    final channel = await _client.users.createDm(user);
    await channel.sendMessage(message);
  }
}

final discordClient = DiscordClient();
