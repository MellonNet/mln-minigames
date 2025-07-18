import "package:nyxx/nyxx.dart" hide Attachment;

import "attachment.dart";
import "utils.dart";

class MessageBody {
  final int id;
  final String subject;
  final String text;

  MessageBody.fromJson(Json json) :
    id = json["id"],
    subject = json["subject"],
    text = json["text"];

  String get shorthand => "$subject: $text";
}

class Message {
  final int id;
  final int senderID;
  final String senderUsername;
  final bool isRead;
  final MessageBody body;
  final List<Attachment> attachments;
  final List<MessageBody> replies;

  Message.fromJson(Json json) :
    id = json["id"],
    senderID = json["sender_id"],
    senderUsername = json["sender_username"],
    isRead = json["is_read"],
    body = MessageBody.fromJson(Json.from(json["body"])),
    attachments = [
      for (final attachmentJson in json["attachments"])
        Attachment.fromJson(Json.from(attachmentJson)),
    ],
    replies = [
      for (final replyJson in json["replies"])
        MessageBody.fromJson(Json.from(replyJson))
    ];

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
