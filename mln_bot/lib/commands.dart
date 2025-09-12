import "package:mln_bot/services.dart";
import "package:nyxx_commands/nyxx_commands.dart";

export "src/commands/befriend.dart";
export "src/commands/block.dart";
export "src/commands/help.dart";
export "src/commands/login.dart";
export "src/commands/logout.dart";
export "src/commands/friend_webhooks.dart";
export "src/commands/mail_webhooks.dart";
export "src/commands/mailbox.dart";
export "src/commands/mini_rank.dart";
export "src/commands/nickname.dart";
export "src/commands/random_user.dart";
export "src/commands/whatis.dart";
export "src/commands/whois.dart";
export "src/commands/who_has.dart";

import "";

final commandsPlugin = CommandsPlugin(
  prefix: mentionOr((_) => "!"),
  options: CommandsOptions(
    defaultResponseLevel: ResponseLevel.hint,
    type: CommandType.slashOnly,
    logErrors: Services.debug,
  ),
);

final subscribeCommand = ChatGroup(
  "subscribe",
  "Get notified in Discord about MLN events",
  children: [
    subscribeMailCommand,
    subscribeFriendCommand,
  ],
);

final unsubscribeCommand = ChatGroup(
  "unsubscribe",
  "Stop Discord notifications for MLN events",
  children: [
    unsubscribeMailCommand,
    unsubscribeFriendCommand,
  ],
);

List<CommandRegisterable> commands = [
  // Users
  befriendCommand,
  unfriendCommand,
  blockCommand,
  unblockCommand,
  userQuery,
  randomUserCommand,
  mailboxCommand,
  nicknameCommand,

  // Items and Modules
  itemQuery,
  itemQueryPublic,
  whoHasCommand,

  // Misc
  loginCommand,
  logoutCommand,
  subscribeCommand,
  unsubscribeCommand,
  helpCommand,
  miniRankCommand,
];
