import "package:mln_shared/data.dart";
import "package:nyxx/nyxx.dart";

extension FriendUtils on Friendship {
  MessageBuilder describe(String username) => MessageBuilder(
    flags: MessageFlags.isComponentsV2,
    components: [
      TextDisplayComponentBuilder(content: describeText(username)),
      if (status == FriendshipStatus.pending)
        ActionRowBuilder(components: [
          ButtonBuilder.danger(
            customId: "friend-delete_${getOther(username)})",
            label: "Delete",
          ),
          ButtonBuilder.primary(
            customId: "friend-add_${getOther(username)}",
            label: "Accept",
          ),
        ]),
    ],
  );
}
