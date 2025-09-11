import "package:mln_bot/services.dart";
import "package:mln_shared/clients.dart";
import "package:nyxx/nyxx.dart";

MessageBuilder buildButton(
  String text,
  ButtonBuilder button,
  {bool isPublic = false}
) => MessageBuilder(
  flags: isPublic
    ? MessageFlags.isComponentsV2
    : MessageFlags.isComponentsV2 | MessageFlags.ephemeral,
  components: [
    TextDisplayComponentBuilder(content: text),
    ActionRowBuilder(components: [button]),
  ]
);

MessageBuilder buildLogin(SessionID sessionID, {bool promptToRetry = false}) {
  final loginUrl = services.server.oauth.getLoginUri(sessionID);
  final message = promptToRetry
    ? "First sign in, then retry your command"
    : "Sign in to get access to all the features!";
  final button = ButtonBuilder.link(
    url: loginUrl,
    label: "Sign in with My Lego Network",
  );
  return buildButton(message, button);
}
