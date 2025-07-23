
import "package:mln_shared/utils.dart";
import "package:uuid/v4.dart";

import "json_client.dart";
import "mln_client.dart";

extension type SessionID(String value) { }
extension type AccessToken(String value) { }

typedef LoginCallback = void Function(SessionID, AccessToken);

class OAuth {
  static const oauthUrl = "${MlnClient.host}/oauth";
  static const tokenUrl = "${MlnClient.host}/oauth/token";

  final JsonClient _client;

  final sessionToTokens = <SessionID, AccessToken>{};
  final tokenToSession = <AccessToken, SessionID>{};
  final accessTokenToUsername = <AccessToken, String>{};

  final String apiToken;
  final String clientID;
  final LoginCallback? loginCallback;
  OAuth({
    required this.apiToken,
    required this.clientID,
    this.loginCallback,
  }) : _client = JsonClient(urlBase: MlnClient.host);

  static SessionID getSessionID() => SessionID(const UuidV4().generate());

  Uri getLoginUri(SessionID sessionID) {
    final uri = Uri.parse(oauthUrl);
    return uri.replace(queryParameters: {
      "client_id": clientID,
      "session_id": sessionID.value,
    });
  }

  Future<AccessToken?> login(SessionID sessionID, String authCode) async {
    final body = {
      "api_token": apiToken,
      "auth_code": authCode,
    };
    final data = await _client.postJson("/oauth/token", body).ignoreApiErrors();
    if (data == null) return null;
    final accessToken = AccessToken(data["access_token"] as String);
    final username = data["username"];
    accessTokenToUsername[accessToken] = username;
    tokenToSession[accessToken] = sessionID;
    sessionToTokens[sessionID] = accessToken;
    loginCallback?.call(sessionID, accessToken);
    return accessToken;
  }
}
