import "utils.dart";

final randomUserCommand = ChatCommand("random-user", "Find a random user", _randomUser);

Future<void> _randomUser(
  ChatContext context, [
  @Choices({
    "My rank": "",
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
  final client = context.getAnyClient();
  final int rankInt;
  if (rank == null || rank.isEmpty) {
    if (client is! MlnClient) {
      return context.respondText("Either specify a rank, or use the /login command to search your rank");
    }
    final user = await client.whoAmI().ignoreApiErrors();
    if (user == null) {
      await context.respondText("Could not find your rank. Try using /logout then /login again");
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
  await context.handle(
    func: () => client.getRandomUser(rankInt),
    onSuccess: (user) => context.respondUser(user, prefix),
  );
}
