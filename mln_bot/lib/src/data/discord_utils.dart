import "package:mln_bot/secrets.dart";
import "package:mln_bot/services.dart";
import "package:mln_shared/clients.dart";
import "package:mln_shared/data.dart";
import "package:mln_shared/utils.dart";
import "package:nyxx/nyxx.dart" hide Webhook, WebhookType;

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

ButtonBuilder buildLoginButton(SessionID sessionID) => ButtonBuilder.link(
  url: services.server.oauth.getLoginUri(sessionID),
  label: "Sign in with My Lego Network",
);

MessageBuilder buildLogin(SessionID sessionID, {bool promptToRetry = false}) {
  final message = promptToRetry
    ? "First sign in, then retry your command"
    : "Sign in to get access to all the features!";
  final button = buildLoginButton(sessionID);
  return buildButton(message, button);
}

const loginText = """
## Oh hey, it's you! You!

Thanks for sharing your account with me -- I feel like we're best friends already!

Now that you've signed in, I can help others find you more easily:
- I gave you a role based on your MLN rank -- don't worry, I'll update this automatically
- I'll show your MLN and Discord usernames when responding to `/who-is` requests
- When you rank up or get a new badge, I'll post about it in https://discord.com/channels/394573245380034573/1415539562381447241
- Starting a new mini-rank? Let me know using `/mini-rank` and I'll give you _another_ role!
- Use `/nickname` and I'll add your MLN username to your MellonNet profile (only on our server)

You've also unlocked more of my features:
- Whenever I post about a user, I'll include a button to send them a friend request
- You can use new commands like `/befriend` and `/mailbox` -- use `/help` to see them all

Want to be kept up to date? Click the buttons below (or use `/subscribe`) and I'll DM you!

-# Uncomfortable? You can log out at any time by using `/logout`
""";

MessageBuilder buildLoginGreeting() => MessageBuilder(
  flags: MessageFlags.isComponentsV2,
  components: [
    TextDisplayComponentBuilder(content: loginText),
    ActionRowBuilder(components: [
      ButtonBuilder.danger(
        customId: "logout_xxx",
        label: "Log out",
      ),
      ButtonBuilder.secondary(
        customId: "subscribe_messages",
        label: "Subscribe to messages",
      ),
      ButtonBuilder.secondary(
        customId: "subscribe_friendships",
        label: "Subscribe to friend requests",
      ),
    ]),
  ],
);

MessageBuilder buildText(String message, {bool isPublic = false}) => MessageBuilder(
  content: message,
  flags: isPublic ? null : MessageFlags.ephemeral,
);

Future<MessageBuilder> subscribeWebhook(MlnClient client, WebhookType type) async {
  var webhook = services.cache.getWebhook(client.accessToken, type);
  if (webhook != null) {
    return buildText("You've already subscribed to $type");
  }
  final url = switch (type) {
    WebhookType.friendships => MlnServer.friendsWebhookUrl,
    WebhookType.messages => MlnServer.messagesWebhookUrl,
  };
  webhook = await client.registerWebhook(
    type: type,
    webhookUrl: url,
    webhookSecret: mlnWebhookApiToken,
  ).ignoreApiErrors();
  if (webhook == null) {
    return buildText("An error occurred");
  }
  await services.cache.saveWebhook(webhook);
  return buildButton(
    "Subscribed! I'll let you know when you get new $type",
    ButtonBuilder.secondary(customId: "unsubscribe_$type", label: "Unsubscribe"),
  );
}
