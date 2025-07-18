import 'package:nyxx/nyxx.dart';

import 'package:mln_bot/secrets.dart';
import 'package:mln_bot/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

void main() async {
  final commands = CommandsPlugin(prefix: mentionOr((_) => "!"));
  commands.addCommand(userQuery);
  final client = await Nyxx.connectGateway(
    discordApiToken, // Replace this with your bot's token
    GatewayIntents.allUnprivileged,
    options: GatewayClientOptions(plugins: [logging, cliIntegration, commands]),
  );


  final botUser = await client.users.fetchCurrentUser();

  client.onMessageCreate.listen((event) async {
    if (event.mentions.contains(botUser)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: 'Hi There!',
        referencedMessage: MessageReferenceBuilder.reply(messageId: event.message.id),
      ));
    }
  });
}