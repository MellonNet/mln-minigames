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

  Future<User?> whoAmI() async {
    final json = await _client.getJson("/users/whoami");
    if (json == null) return null;
    return User.fromJson(json);
  }

  Future<User?> getRandomUser(int rank) async {
    final json = await _client.getJson("/users/random?rank=$rank");
    if (json == null) return null;
    return User.fromJson(json);
  }

  Future<bool> befriend(String username) async {
    final response = await _client.post("/users/$username/friendship");
    return response != null;
  }

  Future<bool> unfriend(String username) async {
    final response = await _client.delete("/users/$username/friendship");
    return response != null;
  }

  Future<bool> block(String username) async {
    final response = await _client.post("/users/$username/block");
    return response != null;
  }

  Future<bool> unblock(String username) async {
    final response = await _client.delete("/users/$username/block");
    return response != null;
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
    final response = await _client.delete("/webhooks/$id");
    return response != null;
  }

  Future<bool> reply(int messageID, int replyID) async {
    final body = {"body_id": replyID};
    final response = await _client.post("/messages/$messageID/reply", body);
    return response != null;
  }

  Future<bool> markAsRead(int messageID) async {
    final response = await _client.post("/messages/$messageID/mark-read");
    return response != null;
  }

  Future<bool> deleteMessage(int messageID) async {
    final response = await _client.delete("/messages/$messageID");
    return response != null;
  }
}
