import "package:nyxx/nyxx.dart" hide Webhook, WebhookType;

import "package:mln_shared/mln_shared.dart" hide User;
import "package:mln_bot/services.dart";
import "package:mln_bot/commands.dart";
import "package:mln_bot/secrets.dart";

import "discord_interactions.dart";
import "discord_utils.dart";

final rankRoles = <String>[
  for (var rank = 0; rank < 11; rank++)
    "Rank $rank",
];

class DiscordClient extends Service with DiscordInteractions {
  @override
  late final NyxxGateway discordClient;

  Snowflake get botID => discordClient.user.id;

  @override
  Future<void> init() async {
    commands.forEach(commandsPlugin.addCommand);
    discordClient = await Nyxx.connectGateway(
      discordApiToken, // Replace this with your bot's token
      GatewayIntents.allUnprivileged,
      options: GatewayClientOptions(
        plugins: [logging, cliIntegration, commandsPlugin, ignoreExceptions],
      ),
    );
    discordClient.setStatus();
    await discordClient.createRoles(rankRoles);
    discordClient.onMessageCreate.listen(_handleNewMessages);
    discordClient.onMessageReactionAdd.listen(_handleReactions);
    discordClient.onMessageComponentInteraction.listen(handleMessageInteractions);
    discordClient.onApplicationCommandInteraction.listen(_handleCommand);
  }

  Future<void> _handleNewMessages(MessageCreateEvent event) async {
    if (event.message.author.id == discordClient.user.id) return;
    if (event.mentions.any((user) => user.id == discordClient.user.id)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: "I don't get it.\n\nSorry, us Discord bots only respond to / commands",
      ));
    }
  }


  Future<void> sendMessage(Snowflake user, MessageBuilder message) async {
    final channel = await discordClient.users.createDm(user);
    await channel.sendMessage(message);
  }

  Future<void> sendToBotChannel(MessageBuilder builder) async {
    const channelID = Snowflake(botChannelID);
    final channel = await discordClient.channels.get(channelID) as GuildTextChannel;
    await channel.sendMessage(builder);
  }

  void _handleCommand(InteractionCreateEvent<ApplicationCommandInteraction> event) {
    final data = event.interaction.data;
    final commandName = data.name;
    services.cache.updateStats(commandName).ignore();
  }

  Future<void> _handleReactions(MessageReactionAddEvent event) async {
    final emoji = event.emoji;
    final isX = emoji.name == "❌";
    final isFromBot = event.messageAuthorId == discordClient.user.id;
    if (!isX || !isFromBot) return;

    final isDm = await event.isDm();
    final isOriginalUser = await event.isOriginalUser();
    if (isDm || isOriginalUser) {
      await event.message.delete();
    }
  }

  Future<void> grantRoleLogin(AccessToken accessToken) async {
    final session = services.cache.sessionsByAccessToken[accessToken];
    if (session == null) return;

    // Get the associated MLN profile
    final client = MlnClient(accessToken, mlnApiToken);
    final profile = await client.whoAmI().ignoreAllErrors();
    if (profile == null) return;

    // Grant the correct role(s)
    await grantRankRole(session.discordID, profile.rank);
  }

  Future<void> grantRankRole(Snowflake userID, int rank) async {
    const serverID = Snowflake(botServerID);
    final server = await discordClient.guilds.get(serverID);
    final member = await server.members.fetch(userID);
    final memberRoles = member.roles;
    for (var otherRank = 0; otherRank < 11; otherRank++) {
      final roleName = rankRoles[otherRank];
      final role = server.roleList.findRole(roleName);
      if (role == null) {
        continue;  // could not find role for some reason
      } else if (rank == otherRank) {  // user should be granted this role
        if (!memberRoles.containsRole(role)) {
          await member.addRole(role.id);
        }
      } else {  // this role should be taken away
        if (memberRoles.containsRole(role)) {
          await member.removeRole(role.id);
        }
      }
    }
  }

  String discordMention(Snowflake id) => "<@$id>";
}
