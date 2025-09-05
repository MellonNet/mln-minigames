import "package:mln_bot/src/clients/utils.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "package:mln_bot/clients.dart";
import "utils.dart";

final randomUserCommand = ChatCommand("random", "Find a random user", _randomUser);

Future<void> _randomUser(
  ChatContext context, [
  @Choices({
    "Your rank": "",
    "Rank 1": "1",
    "Rank 2": "2",
    "Rank 3": "3",
    "Rank 4": "4",
    "Rank 5": "5",
    "Rank 6": "6",
    "Rank 7": "7",
    "Rank 8": "8",
    "Rank 9": "9",
    "Rank 10": "10",
  })
  @Description("Which rank to search")
  String? rank
]) async {
  final client = await context.getClient();
  if (client == null) return;
  final int rankInt;
  if (rank == null || rank.isEmpty) {
    final user = await client.whoAmI().ignoreApiErrors();
    if (user == null) {
      await context.respondText("Either specify a rank, or use the /login command to search your rank");
      return;
    }
    rankInt = user.rank;
  } else {
    final maybeRank = int.tryParse(rank);
    if (maybeRank == null || maybeRank < 0 || maybeRank > 10) {
      return context.respondText("Invalid rank, must be between 0 and 10");
    }
    rankInt = maybeRank;
  }
  const prefix = "Found a random user";
  final description = await client.getRandomUser(rankInt)
    .handle((user) => user.describe(prefix));
  await context.respondText(description);
}
