// We are going to throw [Response]s that represent errors
// ignore_for_file: only_throw_errors

import "package:shelf/shelf.dart";

import "mln.dart";
import "oauth.dart";
import "shelf.dart";
import "utils.dart";

Future<SessionID> _handleOAuth(Request request, OAuth oauth) async {
  final query = request.url.queryParameters;
  final sessionID = query["session_id"] as SessionID?;
  final authCode = query["auth_code"];
  if (sessionID == null || authCode == null) {
    throw Response.badRequest(body: "Missing session_id or auth_code, please try again");
  }
  final accessToken = await safelyAsync(() => oauth.login(sessionID, authCode));
  if (accessToken == null) {
    throw Response.internalServerError(body: "Could not sign in");
  }
  return sessionID;
}

Handler oauthHandler(OAuth oauth) => (Request request) async {
  try {
    await _handleOAuth(request, oauth);
  } on Response catch (response) {
    return response;
  }
  return Response.ok("Authenticated. Please return to Discord");
};

Handler loginHandler(Mln mln) => (Request request) async {
  final AccessToken accessToken;
  final SessionID sessionID;

  try {
    sessionID = await _handleOAuth(request, mln.oauth);
    accessToken = mln.oauth.sessionToTokens[sessionID]!;
  } on Response catch (response) {
    return response;
  }

  final pendingAward = mln.pendingAwards[sessionID];
  print("Found pending award: $pendingAward");
  if (pendingAward != null) {
    final success = await mln.grantReward(
      accessToken: accessToken,
      award: pendingAward,
    );
    if (success) mln.pendingAwards.remove(sessionID);
  }

  return Response.found("/");
};

Handler awardHandler(Mln mln) => (Request request) async {
  final sessionID = request.sessionID;
  if (sessionID == null) return Response.badRequest(body: "Missing session ID");
  final accessToken = mln.oauth.sessionToTokens[sessionID];
  final int awardID;
  try {
    awardID = await request.parseAwardID(
      key: mln.encryptionKey,
      validAwards: mln.validAwards,
    );
  } on FormatException catch (error) {
    return Response.badRequest(body: error.message);
  }
  if (accessToken == null) {
    mln.pendingAwards[sessionID] = awardID;
    final loginXml = mln.oauth.getLoginXml(sessionID);
    final encrypted = encrypt(
      key: mln.encryptionKey,
      source: loginXml,
    );
    return Response.ok(encrypted);
  } else {
    await safelyAsync(() => mln.grantReward(accessToken: accessToken, award: awardID));
    return Response.ok(null);
  }
};
