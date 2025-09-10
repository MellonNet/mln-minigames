import "utils.dart";

final mailboxCommand = ChatCommand(
  "mailbox",
  "Read your latest message",
  _mailbox,
);

Future<void> _mailbox(
  ChatContext context,
) => authedCommand(context,
  (client) => context.handle(
    func: () => client.mailbox(),
    onSuccess: (mailbox) {
      if (mailbox.isEmpty) {
        context.respondText("Your mailbox is empty");
      } else {
        for (final message in mailbox) {
          context.respond(message.describe(isHidden: true));
        }
      }
    },
  ),
);
