import "utils.dart";

final loginCommand = ChatCommand(
  "login",
  "Associates your Discord user with MLN",
  id("login", login),
);

Future<void> login(ChatContext context) async {
  final session = context.session;
  if (session != null) return context.respondText("You are already signed in!");
  await context.respondLogin();
}

final logoutCommand = ChatCommand(
  "logout",
  "Removes your MLN data from Discord",
  id("logout", _logout),
);

Future<void> _logout(ChatContext context) async {
  final session = context.session;
  if (session == null) return context.respondText("You were already signed out!");
  await services.cache.removeSession(session);
  await context.respondText("You've been signed out and unsubscribed");
}
