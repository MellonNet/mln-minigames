import "package:mln_bot/services.dart";
import "package:mln_shared/clients.dart";
import "package:mln_shared/data.dart";
import "package:nyxx/nyxx.dart" hide Attachment, Message, User;

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

extension ItemInfosUtils on Iterable<ItemInfo> {
  MessageBuilder describe({bool isPublic = false}) => MessageBuilder(
    flags: MessageFlags.isComponentsV2 | MessageFlags.ephemeral,
    components: [
      TextDisplayComponentBuilder(content: "Found multiple items that match, please choose one"),
      ActionRowBuilder(components: [
        SelectMenuBuilder.stringSelect(
          customId: "item_$isPublic",
          options: [
            for (final item in this)
              SelectMenuOptionBuilder(label: item.name, value: item.name),
          ]),
      ]),
    ],
  );
}
