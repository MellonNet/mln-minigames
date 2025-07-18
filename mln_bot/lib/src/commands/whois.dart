import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final userQuery = ChatCommand(
  "whois",
  "Gets information about a user",
  userQueryAction,
);

extension on ChatContext {
  Future<void> respondText(String text) => respond(MessageBuilder(content: text));
}

Future<void> userQueryAction(ChatContext context, [String? username]) async {
  if (username == null) {
    await context.respondText("You gotta tell me who you want to know about");
    return;
  }
  final builder = MessageBuilder(content: "How should I know who $username is?");
  await context.respond(builder);
}
