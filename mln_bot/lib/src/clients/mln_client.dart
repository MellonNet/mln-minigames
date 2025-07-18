import "package:mln_bot/data.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_shared/mln_shared.dart";

import "json_client.dart";
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
}
