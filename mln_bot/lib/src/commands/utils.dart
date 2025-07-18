import "package:mln_bot/clients.dart";
import "package:mln_bot/server.dart";
import "package:mln_shared/mln_shared.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

extension ChatUtils on ChatContext {
  Future<void> respondText(String text) => respond(MessageBuilder(content: text));

  /// We hash the snowflake so as not to leak real Discord IDs.
  SessionID get sessionID => SessionID(user.id.hashCode.toString());

  AccessToken? get accessToken => server.oauth.sessionToTokens[sessionID];

  Future<MlnClient?> getClient() async {
    final accessToken = this.accessToken;
    if (accessToken == null) {
      await respondText("You need to sign in first. DM me with the /login command to get a sign-in link!");
      return null;
    } else {
      return MlnClient(accessToken);
    }
  }
}
