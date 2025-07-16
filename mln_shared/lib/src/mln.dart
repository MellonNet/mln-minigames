import "dart:convert";

import "package:http/http.dart";

import "oauth.dart";
import "utils.dart";

class Mln {
  static const baseUrl = "http://localhost:8000";
  static const rewardUrl = "$baseUrl/api/award";

  final String encryptionKey;
  final Set<int> validAwards;
  final pendingAwards = <SessionID, int>{};
  final OAuth oauth;
  Mln({
    required this.oauth,
    required this.encryptionKey,
    required this.validAwards,
  });

  Future<bool> grantReward({
    required AccessToken accessToken,
    required int award,
  }) async {
    final body = {
      "api_token": oauth.apiToken,
      "access_token": accessToken.value,
      "award": award,
    };
    final response = await safelyAsync(() => post(
      Uri.parse(rewardUrl),
      body: jsonEncode(body),
    ));

    if (response == null) {
      print("Error sending POST $rewardUrl");
      return false;
    } else if (response.statusCode != 200) {
      print("Something went wrong: ${response.statusCode} ${response.body}");
      return false;
    } else {
      return true;
    }
  }
}
