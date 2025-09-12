import "package:mln_bot/commands.dart";
import "package:mln_bot/data.dart";
import "package:mln_bot/services.dart";
import "package:nyxx/nyxx.dart";

import "base.dart";
import "utils.dart";

mixin DiscordEvents on BaseDiscordClient {
  void handleCommand(InteractionCreateEvent<ApplicationCommandInteraction> event) {
    final data = event.interaction.data;
    final commandName = data.name;
    services.cache.updateStats(commandName).ignore();
  }

  Future<void> handleReactions(MessageReactionAddEvent event) async {
    final emoji = event.emoji;
    final isX = emoji.name == "❌";
    final isFromBot = event.messageAuthorId == botID;
    if (!isX || !isFromBot) return;

    final isDm = await event.isDm();
    final isOriginalUser = await event.isOriginalUser();
    if (isDm || isOriginalUser) {
      await event.message.delete();
    }
  }

  Future<void> handleNewMessages(MessageCreateEvent event) async {
    if (event.message.author.id == botID) return;
    if (event.mentions.any((user) => user.id == botID)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: "I don't get it.\n\nSorry, us Discord bots only respond to / commands",
      ));
    }
  }

  Future<void> handleNewMember(GuildMemberAddEvent event) async {
    final userID = event.member.id;
    final sessionID = services.cache.discordToMln(userID);
    final loginButton = buildLoginButton(sessionID);
    final builder = buildButton(welcomeText, loginButton);
    await sendMessage(userID, builder);
  }
}
