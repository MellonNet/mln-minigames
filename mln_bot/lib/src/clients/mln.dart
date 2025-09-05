import "package:nyxx/nyxx.dart";

import "package:mln_bot/cache.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_shared/clients.dart";

extension MlnClientUtils on MlnClient {
  Future<String?> checkUsername(String username) async {
    if (!username.startsWith("<@")) return username;
    final discordID = username.substring(2, username.length - 1);
    final snowflake = Snowflake(int.parse(discordID));
    // Lookup the MLN access token
    final sessionID = cache.discordToMln(snowflake);
    final accessToken = cache.sessionToToken[sessionID];
    if (accessToken == null) return null;
    // Find the user based on their access token
    final client2 = MlnClient(accessToken, mlnApiToken);
    final user2 = await client2.whoAmI();
    return user2?.username;
  }
}
