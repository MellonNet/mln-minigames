import "dart:convert";

import "package:uuid/v4.dart";
import "package:http/http.dart";
import "package:xml/xml.dart";


extension type SessionID(String value) { }
extension type AccessToken(String value) { }

const mlnBaseUrl = "http://localhost:8000";

typedef LoginCallback = void Function(SessionID, AccessToken);

class OAuth {
  static const oauthUrl = "$mlnBaseUrl/oauth";
  static const tokenUrl = "$mlnBaseUrl/oauth/token";

  final sessionToTokens = <SessionID, AccessToken>{};
  final accessTokenToUsername = <AccessToken, String>{};

  final String apiToken;
  final String clientID;
  final String loginUrl;
  final LoginCallback? loginCallback;
  OAuth({
    required this.apiToken,
    required this.clientID,
    required this.loginUrl,
    this.loginCallback,
  });

  static SessionID getSessionID() => SessionID(const UuidV4().generate());

  Uri getLoginUri(SessionID sessionID) {
    final uri = Uri.parse(oauthUrl);
    return uri.replace(queryParameters: {
      "client_id": clientID,
      "session_id": sessionID.value,
      "redirect_url": loginUrl,
    });
  }

  String getLoginXml(SessionID sessionID) {
    final builder = XmlBuilder();
    final loginUrl = getLoginUri(sessionID);
    builder.element("result", attributes: {"status": "200"}, nest: () {
      builder.element("message", attributes: {
        "title": "Sign into My Lego Network",
        "text": "We have revived MLN! Please sign in here first",
        "link": loginUrl.toString(),
        "buttonText": "Sign in",
      });
    });
    return builder.buildDocument().toXmlString();
  }

  Future<AccessToken?> login(SessionID sessionID, String authCode) async {
    final body = {
      "api_token": apiToken,
      "auth_code": authCode,
    };
    final response = await post(
      Uri.parse(tokenUrl),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      // Error logs
      // ignore: avoid_print
      print("Error: ${response.statusCode}, ${response.body}");
      return null;
    }
    final data = jsonDecode(response.body);
    final accessToken = AccessToken(data["access_token"] as String);
    final username = data["username"];
    accessTokenToUsername[accessToken] = username;
    sessionToTokens[sessionID] = accessToken;
    loginCallback?.call(sessionID, accessToken);
    return accessToken;
  }
}
