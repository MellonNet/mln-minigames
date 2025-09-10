import "package:nyxx_commands/nyxx_commands.dart";

export "src/commands/befriend.dart";
export "src/commands/block.dart";
export "src/commands/help.dart";
export "src/commands/login.dart";
export "src/commands/logout.dart";
export "src/commands/mail_webhooks.dart";
export "src/commands/random_user.dart";
export "src/commands/webhook_utils.dart";
export "src/commands/whatis.dart";
export "src/commands/whois.dart";

import "";

final commandsPlugin = CommandsPlugin(
  prefix: mentionOr((_) => "!"),
  options: const CommandsOptions(
    defaultResponseLevel: ResponseLevel.hint,
    type: CommandType.slashOnly,
    // logErrors: false,
  ),
);

final subscribeCommand = ChatGroup(
  "subscribe",
  "Get notified in Discord about MLN events",
  children: [
    subscribeMailCommand,
  ],
);

final unsubscribeCommand = ChatGroup(
  "unsubscribe",
  "Stop Discord notifications for MLN events",
  children: [
    unsubscribeMailCommand,
  ],
);

List<CommandRegisterable> commands = [
  befriendCommand,
  randomUserCommand,
  userQuery,
  loginCommand,
  logoutCommand,
  subscribeCommand,
  unsubscribeCommand,
  itemQuery,
  itemQueryPublic,
  unfriendCommand,
  blockCommand,
  unblockCommand,
  helpCommand,
];
