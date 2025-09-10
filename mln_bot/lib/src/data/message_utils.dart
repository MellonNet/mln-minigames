import "package:mln_bot/services.dart";
import "package:mln_shared/clients.dart";
import "package:nyxx/nyxx.dart" hide Attachment, Message, User;

import "package:mln_shared/data.dart";

import "user_utils.dart";

extension MessageUtils on Message {
  static final linkRegex = RegExp(r'a href="(.+)" (.+) \/a');

  String? replaceUrl(String url) {
    if (url.contains("construction.aspx")) {
      return "https://construction.mellonnet.com";
    } else if (url.contains("coastguard.aspx")) {
      return "https://coast-guard.mellonnet.com";
    } else if (url.contains("etwork/default.aspx")) {
      return "https://mln.mellonnet.com";
    } else if (url.contains("elp/default.aspx")) {
      return "https://mellonnet.com/wiki";
    } else if (url.contains("etwork/Pages.aspx")) {
      return "https://mellonnet.com/discord";
    } else if (url.contains("elp/Gettingstarted.aspx")) {
      return "https://mellonnet.com/wiki";
    } else {
      return null;
    }
  }

  String filterLink(Match match) {
    final url = match.group(1);
    final text = match.group(2);
    if (url == null || text == null) return match.group(0)!;
    final replacement = replaceUrl(url);
    return replacement == null
      ? text : "[$text]($replacement)";
  }

  String describeText() {
    final buffer = StringBuffer();
    final filteredBody = body.text
      .replaceAll("[item]", "\n- ")
      .replaceAll("[list]", "\n### ")
      .replaceAll("[/list]", "")
      .replaceAllMapped(linkRegex, filterLink);

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

  MessageBuilder describe({bool isHidden = false}) => MessageBuilder(
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
            customId: isHidden ? "message-delete-hidden_$id" : "message-delete_$id",
            label: "Delete message",
          ),
          ButtonBuilder.link(
            url: Uri.parse("${MlnClient.host}/mln/private_view/default"),
            label: "Go to mailbox",
          ),
          ButtonBuilder.primary(
            customId: isHidden ? "message-read-hidden_$id" : "message-read_$id",
            label: "Mark as Read",
          ),
      ]),
    ],
  );
}
