import "package:nyxx/nyxx.dart";

import "../service.dart";

abstract class BaseDiscordClient extends Service {
  NyxxGateway get discordClient;

  Snowflake get botID => discordClient.user.id;

  Future<void> sendMessage(Snowflake userID, MessageBuilder builder);
}
