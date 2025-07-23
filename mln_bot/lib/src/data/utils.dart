import "package:nyxx/nyxx.dart" hide Attachment, Message;

import "package:mln_shared/data.dart";
export "package:mln_shared/data.dart";

extension MessageUtils on Message {
  MessageBuilder describe() {
    final buffer = StringBuffer();
    buffer.writeln("You got a message from $senderUsername!");
    buffer.writeln("> ### ${body.subject}");
    buffer.writeln("> ${body.text}");
    if (attachments.isNotEmpty) {
      buffer.writeln();
      buffer.writeln("The message has the following attachments: ");
      for (final attachment in attachments) {
        buffer.writeln("- ${attachment.name} x${attachment.qty}");
      }
    }
    return MessageBuilder(
      flags: MessageFlags.isComponentsV2,
      components: [
        TextDisplayComponentBuilder(content: buffer.toString()),
        if (replies.isNotEmpty) ActionRowBuilder(components: [
          SelectMenuBuilder.stringSelect(
            customId: "message_$id",
            options: [
              for (final reply in replies)
                SelectMenuOptionBuilder(
                  label: reply.shorthand,
                  value: reply.id.toString(),
                ),
              ],
            ),
        ]),
      ],
    );
  }
}
