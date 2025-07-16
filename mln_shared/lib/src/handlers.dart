import "package:shelf/shelf.dart";

import "mln.dart";
import "oauth.dart";
import "shelf.dart";
import "utils.dart";

Handler loginHandler(Mln mln) => (Request request) async {
  final query = request.url.queryParameters;
  final sessionID = query["session_id"] as SessionID?;
  final authCode = query["auth_code"];
  if (sessionID == null || authCode == null) {
    return Response.badRequest(body: "Missing session_id or auth_code, please try again");
  }
  final accessToken = await safelyAsync(() => mln.oauth.login(sessionID, authCode));
  print("Signed user in with access token: $accessToken");
  if (accessToken == null) {
    return Response.internalServerError(body: "Could not sign in");
  }
  final pendingReward = mln.pendingAwards[sessionID];
  print("Found pending reward: $pendingReward");
  if (pendingReward != null) {
    final success = await mln.grantReward(
      accessToken: accessToken,
      level: pendingReward,
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
    await safelyAsync(() => mln.grantReward(accessToken: accessToken, level: awardID));
    return Response.ok(null);
  }
};
