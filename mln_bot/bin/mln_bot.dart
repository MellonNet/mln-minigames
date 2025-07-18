import "package:mln_bot/server.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "package:mln_bot/secrets.dart";
import "package:mln_bot/commands.dart";

void main() async {
  await server.init();
  await server.serve();

  final commands = CommandsPlugin(prefix: mentionOr((_) => "!"));
  commands.addCommand(userQuery);
  commands.addCommand(loginCommand);
  final client = await Nyxx.connectGateway(
    discordApiToken, // Replace this with your bot's token
    GatewayIntents.allUnprivileged,
    options: GatewayClientOptions(plugins: [logging, cliIntegration, commands]),
  );

  final botUser = await client.users.fetchCurrentUser();

  client.onMessageCreate.listen((event) async {
    if (event.mentions.contains(botUser)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: "Hi There! I only respond to commands",
        referencedMessage: MessageReferenceBuilder.reply(messageId: event.message.id),
      ));
    }
  });
}
