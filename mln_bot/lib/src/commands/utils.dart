export "package:nyxx/nyxx.dart" hide Attachment, Cache, Message, User, Webhook, WebhookType;
export "package:nyxx_commands/nyxx_commands.dart";

export "package:mln_bot/data.dart";
export "package:mln_bot/secrets.dart";
export "package:mln_bot/services.dart";
export "package:mln_shared/mln_shared.dart";

import "";

typedef ClientCommand = Future<void> Function(MlnClient);
Future<void> authedCommand(ChatContext context, ClientCommand command) async {
  final client = await context.getClient();
  if (client == null) return;
  await command(client);
}

typedef UserCommand = Future<void> Function(String username);
Future<void> userCommand(ChatContext context, String username, UserCommand command) async {
  final realUser = await checkDiscordUser(username);
  if (realUser == null) return context.respondText("That Discord user has not linked their MLN account");
  await command(realUser);
}

Future<String?> checkDiscordUser(String username) async {
  if (!username.startsWith("<@")) return username;
  final discordID = username.substring(2, username.length - 1);
  final snowflake = Snowflake(int.parse(discordID));
  if (snowflake == services.discord.botID) return "Echo";
  return services.cache.sessionsByDiscord[snowflake]?.mlnUsername;
}

Future<void> unsubscribeWebhook(ChatContext context, WebhookType type) => authedCommand(context, (client) async {
  final webhook = services.cache.getWebhook(client.accessToken, type);
  if (webhook == null) return context.respondText("You were not subscribed to $type");
  await context.handle<void>(
    func: () => services.cache.deleteWebhook(webhook),
    onSuccess: (_) => context.respondText("Unsubscribed"),
  );
});

extension ChatUtils on ChatContext {
  Future<void> handle<T>({
    required Future<T?> Function() func,
    required void Function(T) onSuccess,
    String ifNull = "An error occurred",
  }) async {
    try {
      final result = await func();
      if (result == null || result == false) {
        await respondText(ifNull);
      } else {
        onSuccess(result);
      }
    } on ApiException catch (error) {
      await respondText(error.toString());
    // We want to catch any error here
    // ignore: avoid_catches_without_on_clauses
    } catch (error, stack) {
      print(error);
      print(stack);
      await respondText("An error occurred");
    }
  }

  Future<void> respondText(String text, {bool isPublic = false}) => respond(
    MessageBuilder(
      content: text,
      flags: MessageFlags.ephemeral,
    ),
  );

  Future<void> respondUser(User user, String prefix) async =>
    respond(user.describe(prefix));

  Future<void> respondLogin({bool promptToRetry = false}) =>
    respond(buildLogin(services.cache.discordToMln(user.id), promptToRetry: promptToRetry));

  Future<void> respondItem(ItemInfo item, {required bool isPublic}) async =>
    respond(await item.describe(isPublic: isPublic));

  Future<void> respondItems(Iterable<ItemInfo> items, {required bool isPublic}) =>
    respond(items.describe(isPublic: isPublic));

  MellonBotSession? get session => services.cache.sessionsByDiscord[user.id];

  Future<MlnClient?> getClient({bool promptLogin = true}) async {
    final currentSession = session;
    if (currentSession == null) {
      if (promptLogin) await respondLogin(promptToRetry: true);
      return null;
    } else {
      return currentSession.client;
    }
  }

  AnonymousMlnClient getAnonymousClient() => AnonymousMlnClient(mlnApiToken);

  Future<BaseMlnClient> getAnyClient() async =>
    (await getClient(promptLogin: false)) ?? getAnonymousClient();
}
