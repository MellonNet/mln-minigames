import "utils.dart";

final miniRankCommand = ChatCommand(
  "mini-rank",
  "Let people know you're starting a new mini-rank",
  id("minirank", _miniRank),
);

Future<void> _miniRank(
  ChatContext context,
  @Choices(miniRankChoices)
  @Description("Which mini-rank to start")
  String miniRank,
) async {
  final discordID = context.user.id;
  if (!miniRankChoices.keys.contains(miniRank)) {
    return context.respondText("I don't have a role for that");
  }
  final result = await services.discord.toggleRole(discordID, miniRank);
  final message = switch (result) {
    null => "An error occurred",
    true => "Added the $miniRank role to your profile.\n\nYou can `@mention` others in the role to ask for help, or run this command again to remove the role",
    false => "Removed the $miniRank role from your profile."
  };
  await context.respondText(message);
}
