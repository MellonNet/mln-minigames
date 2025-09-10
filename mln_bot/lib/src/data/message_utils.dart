import "package:mln_bot/services.dart";
import "package:mln_shared/clients.dart";
import "package:nyxx/nyxx.dart" hide Attachment, Message, User;

import "package:mln_shared/data.dart";

import "user_utils.dart";

extension MessageUtils on Message {
  String describeText() {
    final buffer = StringBuffer();
    final filteredBody = body.text
      .replaceAll("[item]", "\n- ")
      .replaceAll("[list]", "\n### ")
      .replaceAll("[/list]", "");

    buffer.writeln("## ${body.subject}");
    buffer.writeln(filteredBody);

    if (attachments.isNotEmpty) {
      buffer.writeln("### Attachments:");
      for (final attachment in attachments) {
        buffer.writeln("- ${attachment.name} x${attachment.qty}");
        final item = services.editorial.searchItems(attachment.name).firstOrNull;
        if (item == null) continue;
      }
    }

    return buffer.toString();
  }

  MessageBuilder describe() => MessageBuilder(
    flags: MessageFlags.isComponentsV2,
    components: [
      TextDisplayComponentBuilder(
        content: "You got a message from ${UserUtils.userLink(senderUsername)}!",
      ),
      ContainerComponentBuilder(components: [
        TextDisplayComponentBuilder(content: describeText()),
        if (attachments.isNotEmpty)
          MediaGalleryComponentBuilder(items: [
            for (final attachment in attachments)
              MediaGalleryItemBuilder(
                media: UnfurledMediaItemBuilder(url: services.editorial.getThumbnail(attachment.name)!),
                description: "${attachment.name} x${attachment.qty}",
              ),
          ]),
      ]),
      if (replies.isNotEmpty)
        ActionRowBuilder(components: [
          SelectMenuBuilder.stringSelect(
            placeholder: "Choose a reply",
            customId: "message-reply_$id",
            options: [
              for (final reply in replies)
                SelectMenuOptionBuilder(
                  label: reply.shorthand,
                  value: reply.id.toString(),
                ),
              ],
            ),
        ]),
        ActionRowBuilder(components: [
          ButtonBuilder.danger(
            customId: "message-delete_$id",
            label: "Delete message",
          ),
          ButtonBuilder.link(
            url: Uri.parse("${MlnClient.host}/mln/private_view/default"),
            label: "Go to mailbox",
          ),
          ButtonBuilder.primary(
            customId: "message-read_$id",
            label: "Mark as Read",
          ),
      ]),
    ],
  );
}
