import "utils.dart";

final loginCommand = ChatCommand(
  "login",
  "Associates your Discord user with MLN",
  login,
);

Future<void> login(ChatContext context) async {
  final session = context.session;
  if (session != null) return context.respondText("You are already signed in!");
  await context.respondLogin();
}
