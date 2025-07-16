import "dart:convert";

import "package:http/http.dart";

import "oauth.dart";
import "utils.dart";

class Mln {
  static const baseUrl = "http://localhost:8000";
  static const rewardUrl = "$baseUrl/api/reward";

  final OAuth oauth;
  Mln(this.oauth);

  Future<bool> grantReward({
    required AccessToken accessToken,
    required int level,
  }) async {
    final body = {
      "api_token": oauth.apiToken,
      "access_token": accessToken.value,
      "level": level,
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
