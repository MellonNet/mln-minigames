import "package:mln_bot/services.dart";
import "package:nyxx/nyxx.dart" hide Attachment, Message, User;

import "package:mln_shared/data.dart";

extension UserUtils on User {
  static String userLink(String username) => "[$username](${User.pageUrl(username)})";

  String describeText(String prefix) {
    final buffer = StringBuffer();
    buffer.writeln("$prefix: ${userLink(username)}");
    buffer.writeln("- rank: $rank");
    if (isNetworker) buffer.writeln("- is a networker");
    buffer.writeln("- has ${badges.length} badges");
    if (friendshipStatus != null) {
      buffer.writeln("- ${friendshipStatus!.describe}");
    }
    return buffer.toString();
  }

  MessageBuilder describe(String prefix) => MessageBuilder(
    flags: MessageFlags.isComponentsV2,
    components: [
      TextDisplayComponentBuilder(
        content: describeText(prefix),
      ),
      if (friendshipStatus == FriendshipStatus.none || isNetworker)
        ActionRowBuilder(
          components: [
            if (friendshipStatus == FriendshipStatus.none)
              ButtonBuilder.primary(
                customId: "user_$username",
                label: "Send friend request",
              ),
            if (isNetworker)
              ButtonBuilder.link(label: "Go to Wiki", url: Wiki.buildUriUser(this))
          ],
        ),
      ],
  );
}
