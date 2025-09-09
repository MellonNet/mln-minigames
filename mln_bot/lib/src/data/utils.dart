import "package:mln_bot/services.dart";
import "package:mln_shared/clients.dart";
import "package:nyxx/nyxx.dart" hide Attachment, Message, User;

import "package:mln_shared/data.dart";
import "item_info.dart";

extension MessageUtils on Message {
  Uri pageUrl(String username) => Uri.parse("${MlnClient.host}/mln/public_view/$username");

  MessageBuilder describe() {
    final buffer = StringBuffer();
    // buffer.writeln("You got a message from $senderUsername!");
    buffer.writeln("> ### ${body.subject}");
    buffer.writeln("> ${body.text}");
    // final thumbnails = <Uri>[];
    if (attachments.isNotEmpty) {
      buffer.writeln();
      buffer.writeln("The message has the following attachments: ");
      for (final attachment in attachments) {
        buffer.writeln("- ${attachment.name} x${attachment.qty}");
        final item = services.editorial.searchItems(attachment.name).firstOrNull;
        if (item == null) continue;
        // thumbnails.add(Uri.parse(item.thumbnailUrl));
      }
    }
    return MessageBuilder(
      flags: MessageFlags.isComponentsV2,
      components: [
        TextDisplayComponentBuilder(
          content: "You got a message from ${pageUrl(senderUsername)}!",
        ),
        ContainerComponentBuilder(components: [
          TextDisplayComponentBuilder(content: buffer.toString()),
          if (attachments.isNotEmpty)
            MediaGalleryComponentBuilder(items: [
              for (final attachment in attachments)
                MediaGalleryItemBuilder(
                  media: UnfurledMediaItemBuilder(url: services.editorial.getThumbnail(attachment.name)!),
                  description: "${attachment.name} x${attachment.qty}",
                ),
            ]),
        ]),
        ActionRowBuilder(components: [
          if (replies.isNotEmpty)
            SelectMenuBuilder.stringSelect(
              placeholder: "Choose a reply",
              customId: "message_$id",
              options: [
                for (final reply in replies)
                  SelectMenuOptionBuilder(
                    label: reply.shorthand,
                    value: reply.id.toString(),
                  ),
                ],
              ),
            ButtonBuilder.secondary(
              customId: "mark-read_$id",
              label: "Mark as Read",
            ),
            ButtonBuilder.link(
              url: Uri.parse("${MlnClient.host}/mln/private_view/default"),
              label: "Go to mailbox",
            )
        ]),
      ],
    );
  }
}

extension ItemUtils on ItemInfo {
  Future<String> describeText() async {
    final wikiItem = await services.wiki.getItem(this);
    final buffer = StringBuffer();
    buffer.writeln("Sure! Sure! Here's what I know about $name:");
    buffer.writeln();
    buffer.writeln(description);
    buffer.writeln();
    if (wikiItem != null) {
      buffer.writeln("Here's what I found on the wiki: ");
      buffer.writeln("- **How to obtain**: ${wikiItem.howToObtain}");
      buffer.writeln("- **Cost to build**: ${wikiItem.costToBuild}");
    } else {
      buffer.writeln("I couldn't find any information about that on the wiki.");
    }
    return buffer.toString();
  }

  Uri get thumbnailUrl => Uri.parse("${MlnClient.host}$thumbnailPath");

  Future<MessageBuilder> describe({bool isPublic = false}) async => MessageBuilder(
    flags: isPublic
      ? MessageFlags.isComponentsV2
      : MessageFlags.isComponentsV2 | MessageFlags.ephemeral,
    components: [
      SectionComponentBuilder(
        components: [
          TextDisplayComponentBuilder(content: await describeText())
        ],
        accessory: ThumbnailComponentBuilder(
          media: UnfurledMediaItemBuilder(url: thumbnailUrl),
        ),
      ),
      ActionRowBuilder(components: [
        ButtonBuilder.link(url: Wiki.buildUriItem(this), label: "Go to Wiki"),
      ]),
    ]
  );
}

extension UserUtils on User {
  String describeText(String prefix) {
    final buffer = StringBuffer();
    buffer.writeln("$prefix: [$username]($fullUrl)");
    buffer.writeln("- rank: $rank");
    if (isNetworker) buffer.writeln("- is a networker");
    buffer.writeln("- has ${badges.length} badges");
    buffer.writeln("- ${friendshipStatus.describe}");
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

extension StringUtils on String {
  bool fuzzyMatch(String query) {
    final parts = toLowerCase().split(" ");
    return query.toLowerCase().split(" ")
      .every((queryPart) => parts.any((part) => part.contains(queryPart)));
  }

  bool caseInsensitive(String other) => toLowerCase() == other.toLowerCase();

  bool containsInsensitive(String other) => toLowerCase().contains(other.toLowerCase());

  (String, String)? splitFirst(String pattern) {
    final index = indexOf(pattern);
    if (index == -1) return null;
    return (substring(0, index), substring(index + 1));
  }
}
