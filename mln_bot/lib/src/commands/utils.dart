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
  return services.cache.sessionsByDiscord[snowflake]?.mlnUsername;
}

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

  Future<void> respondUser(User user, String prefix) =>
    respond(user.describe(prefix));

  Future<void> respondLogin({bool promptToRetry = false}) =>
    respond(buildLogin(services.cache.discordToMln(user.id), promptToRetry: promptToRetry));

  Future<void> respondItem(ItemInfo item, {required bool isPublic}) async =>
    respond(await item.describe(isPublic: isPublic));

  Future<void> respondItems(List<ItemInfo> items, {required bool isPublic}) => respond(
    MessageBuilder(
      flags: MessageFlags.isComponentsV2 | MessageFlags.ephemeral,
      components: [
        TextDisplayComponentBuilder(content: "Found multiple items that match, please choose one"),
        ActionRowBuilder(components: [
          SelectMenuBuilder.stringSelect(
            customId: "item_$isPublic",
            options: [
              for (final item in items)
                SelectMenuOptionBuilder(label: item.name, value: item.name),
            ]),
        ]),
      ],
    ),
  );

  AccessToken? get accessToken => services.cache.sessionsByDiscord[user.id]?.accessToken;

  Future<MlnClient?> getClient({bool promptLogin = true}) async {
    final accessToken = this.accessToken;
    if (accessToken == null) {
      if (promptLogin) await respondLogin(promptToRetry: true);
      return null;
    } else {
      return MlnClient(accessToken, mlnApiToken);
    }
  }

  AnonymousMlnClient getAnonymousClient() => AnonymousMlnClient(mlnApiToken);

  Future<BaseMlnClient> getAnyClient() async =>
    (await getClient(promptLogin: false)) ?? getAnonymousClient();
}
