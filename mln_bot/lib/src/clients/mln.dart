import "package:mln_bot/data.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_bot/server.dart";
import "package:mln_shared/mln_shared.dart";

import "json.dart";
import "utils.dart";

class MlnClient {
  static const host = "http://localhost:8000";

  final AccessToken accessToken;
  final JsonClient _client;

  static MlnHeaders authHeaders(AccessToken accessToken) => {
    "Authorization": "Bearer $accessToken",
    "Api-Token": mlnApiToken,
  };

  MlnClient(this.accessToken) :
    _client = JsonClient(urlBase: "$host/api", authHeaders: authHeaders(accessToken));

  void dispose() => _client.dispose();

  Future<User?> getUser(String username) async {
    final json = await _client.getJson("/users/$username");
    if (json == null) return null;
    return User.fromJson(json);
  }

  Future<String?> befriend(String username) async {
    final response = await _client.post("/users/$username/friendship");
    if (response == null) return null;
    return "Sent a friend request to $username";
  }

  Future<WebhookID?> registerMailWebhook() async {
    final body = {
      "webhook_url": MlnServer.messagesWebhookUrl,
      "mln_secret": mlnWebhookApiToken,
      "type": "messages",
    };
    final response = await _client.postJson("/webhooks", body);
    if (response == null) return null;
    return WebhookID(response["webhook_id"]);
  }

  Future<bool> deleteWebhook(WebhookID id) async {
    final response = await tryAsync(() => _client.delete("/webhooks/$id"));
    return response != null;
  }

  Future<bool> reply(int messageID, int replyID) async {
    final body = {"body_id": replyID};
    final response = await _client.post("/messages/$messageID/reply", body);
    if (response == null) return false;
    return true;
  }
}
