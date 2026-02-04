import "utils.dart";

final nicknameCommand = ChatCommand(
  "nickname",
  "Add your nickname to your MellonNet server profile",
  id("nickname", _nickname),
);

Future<void> _nickname(
  ChatContext context,
) async {
  final session = context.session;
  if (session == null) return context.respondLogin(promptToRetry: true);
  await context.handle(
    func: () => services.discord.setNickname(session),
    onSuccess: (newNickname) => context.respondText("Your nickname is now $newNickname"),
  );
}
