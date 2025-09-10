import "package:mln_shared/data.dart";
import "package:mln_shared/utils.dart";

import "json_client.dart";
import "oauth.dart";

extension type WebhookID(int id) { }

final class BaseMlnClient {
  final JsonClient _client;
  BaseMlnClient(this._client);

  Future<User?> getUser(String username) async {
    final json = await _client.getJson("/users/$username");
    if (json == null) return null;
    return User.fromJson(json);
  }

  Future<User?> getRandomUser(int rank) async {
    final json = await _client.getJson("/users/random?rank=$rank");
    if (json == null) return null;
    return User.fromJson(json);
  }
}

final class AnonymousMlnClient extends BaseMlnClient {
  AnonymousMlnClient(String apiToken) : super(
    JsonClient(
      urlBase: "${MlnClient.host}/api",
      authHeaders: MlnClient.authHeaders(apiToken: apiToken),
    ),
  );
}

final class MlnClient extends BaseMlnClient {
  static const host = "https://mln.mellonnet.com";

  static MlnHeaders authHeaders({
    required String apiToken,
    AccessToken? accessToken,
  }) => {
    if (accessToken != null) "Authorization": "Bearer $accessToken",
    "Api-Token": apiToken,
  };

  final AccessToken accessToken;

  MlnClient(this.accessToken, String apiToken) : super(
    JsonClient(
      urlBase: "$host/api",
      authHeaders: authHeaders(accessToken: accessToken, apiToken: apiToken),
    ),
  );

  void dispose() => _client.dispose();

  Future<bool> grantAward(int award) async {
    final body = { "award": award };
    final response = await _client.post("/award", body).ignoreApiErrors();
    return response != null;
  }

  Future<User?> whoAmI() async {
    final json = await _client.getJson("/users/whoami");
    if (json == null) return null;
    return User.fromJson(json);
  }

  Future<bool> befriend(String username) async {
    final response = await _client.post("/users/$username/friendship");
    return response != null;
  }

  Future<bool> unfriend(String username) => _client.delete("/users/$username/friendship");

  Future<bool> block(String username) async {
    final response = await _client.post("/users/$username/block");
    return response != null;
  }

  Future<bool> unblock(String username) => _client.delete("/users/$username/block");

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

  Future<bool> deleteWebhook(WebhookID id) => _client.delete("/webhooks/$id");

  Future<bool> reply(int messageID, int replyID) async {
    final body = {"body_id": replyID};
    final response = await _client.post("/messages/$messageID/reply", body);
    return response != null;
  }

  Future<bool> markAsRead(int messageID) async {
    final response = await _client.post("/messages/$messageID/mark-read");
    return response != null;
  }

  Future<bool> deleteMessage(int messageID) => _client.delete("/messages/$messageID");
}
