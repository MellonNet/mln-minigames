import "package:shelf/shelf.dart";

import "package:mln_shared/mln_shared.dart";

const validAwards = {1, 2, 3, 4, 5};

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
