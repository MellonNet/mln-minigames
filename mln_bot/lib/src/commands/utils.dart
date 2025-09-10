import "package:mln_bot/data.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_bot/services.dart";
import "package:mln_shared/data.dart" as mln;
import "package:mln_shared/clients.dart";
import "package:mln_shared/utils.dart";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

export "package:mln_shared/mln_shared.dart";

Future<String?> checkUsername(String username) async {
  if (!username.startsWith("<@")) return username;
  final discordID = username.substring(2, username.length - 1);
  final snowflake = Snowflake(int.parse(discordID));
  // Lookup the MLN access token
  final sessionID = services.cache.discordToMln(snowflake);
  final accessToken = services.cache.sessionToToken[sessionID];
  if (accessToken == null) return null;
  // Find the user based on their access token
  final client2 = MlnClient(accessToken, mlnApiToken);
  final user2 = await client2.whoAmI();
  return user2?.username;
}

extension ChatUtils on ChatContext {
  Future<void> handle<T>({
    required Future<T?> Function() func,
    required void Function(T) onSuccess,
    String ifNull = "An error occurred",
  }) async {
    try {
      final result = await func();
      if (result == null) {
        await respondText(ifNull);
      } else {
        onSuccess(result);
      }
    } on ApiException catch (error) {
      await respondText(error.toString());
    // We want to catch any error here
    // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      await respondText("An error occurred");
    }
  }

  Future<void> respondText(String text, {bool isPublic = false}) => respond(
    MessageBuilder(
      flags: isPublic
        ? MessageFlags.ephemeral
        : MessageFlags.ephemeral | MessageFlags.isComponentsV2,
      components: [
        TextDisplayComponentBuilder(content: text),
      ],
    ),
  );

  Future<void> respondLink(String label, Uri uri) => respond(
    MessageBuilder(
      flags: MessageFlags.isComponentsV2,
      components: [
        ActionRowBuilder(components: [
          ButtonBuilder.link(url: uri, label: label),
        ]),
      ],
    ),
  );

  Future<void> respondUser(mln.User user, String prefix) =>
    respond(user.describe(prefix));

  Future<void> respondLogin() async {
    final loginUrl = services.server.oauth.getLoginUri(sessionID);
    await respondLink("Sign in with My Lego Network", loginUrl);
  }

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

  /// We hash the snowflake so as not to leak real Discord IDs.
  SessionID get sessionID => services.cache.discordToMln(user.id);

  AccessToken? get accessToken => services.server.oauth.sessionToTokens[sessionID];

  Future<MlnClient?> getClient({bool promptLogin = true}) async {
    final accessToken = this.accessToken;
    if (accessToken == null) {
      if (promptLogin) await respondLogin();
      return null;
    } else {
      return MlnClient(accessToken, mlnApiToken);
    }
  }

  AnonymousMlnClient getAnonymousClient() => AnonymousMlnClient(mlnApiToken);

  Future<BaseMlnClient> getAnyClient() async =>
    (await getClient(promptLogin: false)) ?? getAnonymousClient();
}
