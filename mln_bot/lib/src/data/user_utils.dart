import "package:mln_bot/data.dart";
import "package:mln_bot/services.dart";
import "package:mln_shared/utils.dart";
import "package:nyxx/nyxx.dart" hide Attachment, Message, User;

import "package:mln_shared/data.dart";

extension UserUtils on User {
  static String userLink(String username) => "[$username](${User.pageUrl(username)})";

  Snowflake? getDiscordID() => username.toLowerCase() == "echo"
    ? services.discord.botID
    : services.cache.sessionsByMlnUsername[username]?.discordID;

  String describeText(String prefix) {
    final buffer = StringBuffer();
    buffer.writeln("$prefix: ${userLink(username)}");
    buffer.writeln("- rank: $rank");
    if (isNetworker) buffer.writeln("- is a networker");
    buffer.writeln("- has ${badges.length} badges");
    if (friendshipStatus != null) {
      buffer.writeln("- ${friendshipStatus!.describe}");
    }
    final discordID = getDiscordID();
    if (discordID != null) {
      final mention = services.discord.discordMention(discordID);
      buffer.writeln("- is signed into Discord as $mention");
    }
    return buffer.toString();
  }

  MessageBuilder describe(String prefix) => MessageBuilder(
    flags: MessageFlags.isComponentsV2 | MessageFlags.ephemeral,
    components: [
      TextDisplayComponentBuilder(
        content: describeText(prefix),
      ),
      if (friendshipStatus == FriendshipStatus.none || isNetworker)
        ActionRowBuilder(
          components: [
            if (friendshipStatus == FriendshipStatus.none)
              ButtonBuilder.primary(
                customId: "friend-add_$username",
                label: "Send friend request",
              ),
            if (isNetworker)
              ButtonBuilder.link(label: "Go to Wiki", url: Wiki.buildUriUser(this))
          ],
        ),
      ],
  );
}

extension ListUserUtils on List<User> {
  User? pickRandomUser({bool allowNetworker = false}) {
    final discordUsers = <User>[];
    final nonDiscordUsers = <User>[];
    for (final user in this) {
      final session = services.cache.sessionsByMlnUsername[user.username];
      if (user.isNetworker && !allowNetworker) continue;
      if (session == null) {
        nonDiscordUsers.add(user);
      } else {
        discordUsers.add(user);
      }
    }

    return discordUsers.getRandom() ?? nonDiscordUsers.getRandom();
  }
}

MessageBuilder pickPreferredUser(ItemInfo item, List<User> ready, List<User> notReady) {
  var user = ready.pickRandomUser() ?? notReady.pickRandomUser();
  if (user == null) {
    var message = "Nobody has a $item on their page -- you should be the first!";
    user = ready.pickRandomUser(allowNetworker: true);
    if (user != null) {
      message += "\n\nOne of my Networker friends does, though";
      return user.describe(message);
    } else {
      return buildText(message);
    }
  } else {
    var message = "This user has a ${item.name} on their page";
    if (notReady.contains(user)) message += " -- but it's not setup";
    return user.describe(message);
  }
}
