import "package:mln_shared/src/clients/oauth.dart";
import "package:mln_shared/utils.dart";
import "package:shelf/shelf.dart";
import "package:xml/xml.dart";

class MlnMinigame {
  final OAuth oauth;
  final Set<int> validAwards;
  final String encryptionKey;

  final pendingAwards = <SessionID, int>{};

  MlnMinigame({
    required this.encryptionKey,
    required this.oauth,
    required this.validAwards,
  });

  String getLoginXml(SessionID sessionID) {
    final builder = XmlBuilder();
    final loginUrl = oauth.getLoginUri(sessionID);
    builder.element("result", attributes: {"status": "200"}, nest: () {
      builder.element("message", attributes: {
        "title": "Sign into My Lego Network",
        "text": "We have revived MLN! Please sign in here first",
        "link": loginUrl.toString(),
        "buttonText": "Sign in",
      });
    });
    final xmlString = builder.buildDocument().toXmlString();
    return encrypt(key: encryptionKey, source: xmlString);
  }

  Future<int?> parseAwardID(Request request) async {
    final body = await request.readAsString();
    final queryString = Uri.decodeFull(body);
    final query = Uri.splitQueryString(queryString);
    final encryptedCode = query["awardCode"];
    if (encryptedCode == null) throw const FormatException("Missing awardCode");
    final awardCode = decrypt(key: encryptionKey, source: encryptedCode);
    if (awardCode.isEmpty) throw const FormatException("Missing awardCode");
    final awardID = int.tryParse(awardCode.split("").last);
    if (awardID == null || !validAwards.contains(awardID)) {
      return null;
    }
    return awardID;
  }
}
