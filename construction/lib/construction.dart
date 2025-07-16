import "package:mln_shared/mln_shared.dart";
import "package:shelf/shelf.dart";

const validAwards = {1, 2, 4, 5, 6, 7};
const key = "13bv9cyruhnflksjhtf+p1q";

Future<int> parseAwardID(Request request) async {
  final body = await request.readAsString();
  final queryString = Uri.decodeFull(body);
  final query = Uri.splitQueryString(queryString);
  final encryptedCode = query["awardCode"];
  if (encryptedCode == null) throw const FormatException("Missing awardCode");
  final awardCode = decrypt(key: key, source: encryptedCode);
  if (awardCode.isEmpty) throw const FormatException("Missing awardCode");
  final awardID = int.tryParse(awardCode.split("").last);
  if (awardID == null || !validAwards.contains(awardID)) {
    throw FormatException("Invalid awardCode: $awardID");
  }
  return awardID;
}

const constructionBase = "http://localhost:7001";
const constructionLoginUrl = "$constructionBase/api/login";
final oauth = OAuth(apiToken: "123", clientID: "123", loginUrl: constructionLoginUrl);
final mln = Mln(oauth);

Future<Response> handleAwards(Request request) async {
  final sessionID = request.sessionID;
  if (sessionID == null) return Response.badRequest(body: "Missing session ID");
  final accessToken = mln.oauth.sessionToTokens[sessionID];
  final int awardID;
  try {
    awardID = await parseAwardID(request);
  } on FormatException catch (error) {
    return Response.badRequest(body: error.message);
  }
  if (accessToken == null) {
    // pendingRankAwards[sessionID] = awardID;
    final loginXml = mln.oauth.getLoginXml(sessionID);
    final encrypted = encrypt(key: key, source: loginXml);
    return Response.ok(encrypted);
  } else {
    await safelyAsync(() => mln.grantReward(accessToken: accessToken, level: awardID));
    return Response.ok(null);
  }
}

Future<Response> loginHandler(Request request) async {
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
  // final pendingReward = pendingRankAwards[sessionID];
  // print("Found pending reward: $pendingReward");
  // if (pendingReward != null) {
  //   final success = await mln.grantReward(
  //     accessToken: accessToken,
  //     level: pendingReward,
  //   );
  //   // if (success) pendingRankAwards.remove(sessionID);
  // }

  return Response.found("/");
}
