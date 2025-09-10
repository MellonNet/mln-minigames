import "package:mln_shared/clients.dart";
import "package:mln_shared/utils.dart";

extension type WebhookID(int id) { }

enum WebhookType {
  // These names must stay consistent with the MLN API.
  messages,
  friendships;

  @override
  String toString() => name;
}

class Webhook {
  final WebhookType type;
  final WebhookID id;
  final AccessToken accessToken;

  Webhook.fromJson(Json json) :
    id = WebhookID(json["webhook_id"]),
    type = WebhookType.values.byName(json["type"]),
    accessToken = AccessToken(json["access_token"]);

  Json toJson() => {
    "webhook_id": id,
    "type": type.name,
    "access_token": accessToken,
  };
}
