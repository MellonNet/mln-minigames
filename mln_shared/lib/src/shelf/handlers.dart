// We are going to throw [Response]s that represent errors
// ignore_for_file: only_throw_errors

import "package:mln_shared/clients.dart";
import "package:shelf/shelf.dart";

import "shelf.dart";
import "minigame.dart";

Future<SessionID> _handleOAuth(Request request, OAuth oauth) async {
  final query = request.url.queryParameters;
  final sessionID = query["session_id"] as SessionID?;
  final authCode = query["auth_code"];
  if (sessionID == null || authCode == null) {
    throw Response.badRequest(body: "Missing session_id or auth_code, please try again");
  }
  final accessToken = await oauth.login(sessionID, authCode);
  if (accessToken == null) {
    throw Response.internalServerError(body: "Could not sign in");
  }
  return sessionID;
}

Handler loginHandler(OAuth oauth) => (Request request) async {
  try {
    await _handleOAuth(request, oauth);
  } on Response catch (response) {
    return response;
  }
  return Response.ok("Authenticated. Please return to Discord");
};

Handler minigameLoginHandler(MlnMinigame minigame) => (Request request) async {
  final AccessToken accessToken;
  final SessionID sessionID;

  try {
    sessionID = await _handleOAuth(request, minigame.oauth);
    accessToken = minigame.oauth.sessionToTokens[sessionID]!;
  } on Response catch (response) {
    return response;
  }

  final pendingAward = minigame.pendingAwards[sessionID];
  print("Found pending award: $pendingAward");
  if (pendingAward != null) {
    final mlnClient = MlnClient(accessToken, minigame.oauth.apiToken);
    final success = await mlnClient.grantAward(pendingAward);
    if (success) minigame.pendingAwards.remove(sessionID);
  }

  return Response.found("/");
};

Handler minigameAwardHandler(MlnMinigame minigame) => (Request request) async {
  final sessionID = request.sessionID;
  if (sessionID == null) return Response.badRequest(body: "Missing session ID");
  final accessToken = minigame.oauth.sessionToTokens[sessionID];
  final awardID = await minigame.parseAwardID(request);
  if (awardID == null) return Response.badRequest(body: "Missing or invalid award ID. Valid awards: ${minigame.validAwards}");

  if (accessToken == null) {
    minigame.pendingAwards[sessionID] = awardID;
    final loginXml = minigame.getLoginXml(sessionID);
    return Response.ok(loginXml);
  } else {
    final mlnClient = MlnClient(accessToken, minigame.oauth.apiToken);
    await mlnClient.grantAward(awardID);
    return Response.ok(null);
  }
};
