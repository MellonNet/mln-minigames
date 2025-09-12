import "utils.dart";

final logoutCommand = ChatCommand("logout", "Removes your MLN data from Discord", _logout);

Future<void> _logout(ChatContext context) async {
  final session = context.session;
  if (session == null) return context.respondText("You were already signed out!");
  await services.cache.removeSession(session);
  await context.respondText("Done");
}
