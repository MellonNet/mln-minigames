import "package:mln_bot/secrets.dart";
import "package:mln_bot/server.dart";
import "package:mln_bot/cache.dart";
import "package:mln_shared/clients.dart";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

export "package:mln_shared/mln_shared.dart";

extension ChatUtils on ChatContext {
  Future<void> respondText(String text) => respond(MessageBuilder(content: text));

  Future<Message> respondLink(String label, Uri uri) => respond(
    MessageBuilder(
      flags: MessageFlags.isComponentsV2,
      components: [
        ActionRowBuilder(components: [
          ButtonBuilder.link(url: uri, label: label),
        ]),
      ],
    ),
  );

  /// We hash the snowflake so as not to leak real Discord IDs.
  SessionID get sessionID => cache.discordToMln(user.id);

  AccessToken? get accessToken => server.oauth.sessionToTokens[sessionID];

  Future<MlnClient?> getClient() async {
    final accessToken = this.accessToken;
    if (accessToken == null) {
      await respondText("You need to sign in first. Use the /login command to get a sign-in link!");
      return null;
    } else {
      return MlnClient(accessToken, mlnApiToken);
    }
  }
}
