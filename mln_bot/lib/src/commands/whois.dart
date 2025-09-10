import "utils.dart";

final userQuery = ChatCommand(
  "who-is",
  "Gets information about a user",
  userQueryAction,
);

Future<void> userQueryAction(
  ChatContext context,
  @Description("The MLN or Discord user to search")
  String username,
) => userCommand(context, username, (user) async {
  final client = await context.getAnyClient();
  const prefix = "Sure! Sure! Here's what I know about";
  await context.handle(
    func: () => client.getUser(user),
    onSuccess: (user) => context.respondUser(user, prefix),
    ifNull: "Could not find user $user",
  );
});
