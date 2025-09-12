import "package:nyxx/nyxx.dart" hide Webhook, WebhookType;

import "package:mln_shared/mln_shared.dart" hide User;
import "package:mln_bot/data.dart";
import "package:mln_bot/commands.dart";
import "package:mln_bot/secrets.dart";

import "discord/base.dart";
import "discord/events.dart";
import "discord/interactions.dart";
import "discord/utils.dart";

class DiscordClient extends BaseDiscordClient with DiscordInteractions, DiscordEvents {
  @override
  late final NyxxGateway discordClient;

  @override
  Future<void> init() async {
    commands.forEach(commandsPlugin.addCommand);
    discordClient = await Nyxx.connectGateway(
      discordApiToken,
      GatewayIntents.allUnprivileged | GatewayIntents.guildMembers,
      options: GatewayClientOptions(
        plugins: [logging, cliIntegration, commandsPlugin, ignoreExceptions],
      ),
    );
    await discordClient.createRoles(names: rankRoles, color: rankColor, isHoisted: true);
    await discordClient.createRoles(names: miniRankRoles, color: miniRankColor, isHoisted: false);
    discordClient.setStatus();
    discordClient.onMessageCreate.listen(handleNewMessages);
    discordClient.onMessageReactionAdd.listen(handleReactions);
    discordClient.onMessageComponentInteraction.listen(handleMessageInteractions);
    discordClient.onApplicationCommandInteraction.listen(handleCommand);
    discordClient.onGuildMemberAdd.listen(handleNewMember);
  }

  @override
  Future<void> sendMessage(Snowflake user, MessageBuilder builder) async {
    final channel = await discordClient.users.createDm(user);
    await channel.sendMessage(builder);
  }

  Future<void> sendToBotChannel(MessageBuilder builder) async {
    const channelID = Snowflake(botChannelID);
    final channel = await discordClient.channels.get(channelID) as GuildTextChannel;
    await channel.sendMessage(builder);
  }

  Future<void> handleLogin(MellonBotSession session) async {
    // Send a welcome message
    final builder = buildLoginGreeting();
    await sendMessage(session.discordID, builder);

    // Assign the right role for this user's rank
    final profile = await session.client.whoAmI().ignoreAllErrors();
    if (profile == null) return;
    await grantRankRole(session.discordID, profile.rank);
  }

  Future<String> setNickname(MellonBotSession session) async {
    const serverID = Snowflake(botServerID);
    final server = await discordClient.guilds.get(serverID);
    final member = await server.members.get(session.discordID);
    final currentName = member.nick ?? member.user?.globalName ?? "";
    if (currentName.contains(session.mlnUsername)) return currentName;
    final newName = "$currentName (${session.mlnUsername})";
    final builder = MemberUpdateBuilder(nick: newName);
    await member.update(builder);
    return newName;
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

  Future<bool?> toggleRole(Snowflake discordID, String roleName) async {
    const serverID = Snowflake(botServerID);
    final server = await discordClient.guilds.get(serverID);
    final member = await server.members.fetch(discordID);
    final role = server.roleList.findRole(roleName);
    if (role == null) return null;
    final memberRoles = member.roles;
    if (memberRoles.containsRole(role)) {
      await member.removeRole(role.id);
      return false;
    } else {
      await member.addRole(role.id);
      return true;
    }
  }
}
