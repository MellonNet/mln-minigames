import "package:mln_bot/cache.dart";
import "package:mln_bot/server.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "package:mln_bot/secrets.dart";
import "package:mln_bot/commands.dart";

void main() async {
  // Open OAuth server
  await cache.init();
  await server.serve();

  // Register Discord commands
  final commands = CommandsPlugin(
    prefix: mentionOr((_) => "!"),
    options: const CommandsOptions(
      defaultResponseLevel: ResponseLevel.hint,
      type: CommandType.slashOnly,
      logErrors: false,
    ),
  );

  commands.addCommand(befriendCommand);
  commands.addCommand(loginCommand);
  commands.addCommand(logoutCommand);
  commands.addCommand(userQuery);

  // Connect the client
  final client = await Nyxx.connectGateway(
    discordApiToken, // Replace this with your bot's token
    GatewayIntents.allUnprivileged,
    options: GatewayClientOptions(plugins: [logging, cliIntegration, commands]),
  );

  // Reject all incoming mentions
  final botUser = await client.users.fetchCurrentUser();
  client.onMessageCreate.listen((event) async {
    if (event.mentions.contains(botUser)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: "I don't get it.\n\nSorry, us Discord bots only respond to / commands",
      ));
    }
  });

  client.updatePresence(
    PresenceBuilder(
      activities: [
        ActivityBuilder(
          name: "My Lego Network",
          type: ActivityType.game,
          state: "Baking an Apple Pie",
          url: Uri.parse("https://mln.lcdruniverse.org"),
        ),
      ],
      status: CurrentUserStatus.online,
      isAfk: false,
      since: DateTime.now(),
    ),
  );
}
