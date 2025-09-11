import "utils.dart";

final logoutCommand = ChatCommand("logout", "Removes your MLN data from Discord", _logout);

Future<void> _logout(ChatContext context) async {
  final accessToken = context.accessToken;
  if (accessToken == null) return context.respondText("You were already signed out!");
  await services.cache.removeSession(context.user.id);
  await context.respondText("Done");
}
