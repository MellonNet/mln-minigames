import "package:mln_shared/data.dart";
import "package:mln_shared/utils.dart";

import "json_client.dart";
import "oauth.dart";

extension type WebhookID(int id) { }

class MlnClient {
  static const host = "https://mln.mellonnet.com";
  // static const host = "http://localhost:8000";

  final AccessToken accessToken;
  final JsonClient _client;

  static MlnHeaders authHeaders({
    required AccessToken accessToken,
    required String apiToken,
  }) => {
    "Authorization": "Bearer $accessToken",
    "Api-Token": apiToken,
  };

  MlnClient(this.accessToken, String apiToken) :
    _client = JsonClient(
      urlBase: "$host/api",
      authHeaders: authHeaders(accessToken: accessToken, apiToken: apiToken),
    );

  void dispose() => _client.dispose();

  Future<bool> grantAward(int award) async {
    final body = { "award": award };
    final response = await _client.post("/award", body).ignoreApiErrors();
    return response != null;
  }

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

  Future<WebhookID?> registerMailWebhook(String webhookUrl, String webhookSecret) async {
    final body = {
      "webhook_url": webhookUrl,
      "mln_secret": webhookSecret,
      "type": "messages",
    };
    final response = await _client.postJson("/webhooks", body);
    if (response == null) return null;
    return WebhookID(response["webhook_id"]);
  }

  Future<bool> deleteWebhook(WebhookID id) async {
    final response = await _client.delete("/webhooks/$id").ignoreApiErrors();
    return response != null;
  }

  Future<bool> reply(int messageID, int replyID) async {
    final body = {"body_id": replyID};
    final response = await _client.post("/messages/$messageID/reply", body);
    if (response == null) return false;
    return true;
  }
}
