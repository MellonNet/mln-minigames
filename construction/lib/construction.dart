import "package:mln_shared/mln_shared.dart";

import "secrets.dart";

const validAwards = {1, 2, 4, 5, 6, 7};
const flashKey = "13bv9cyruhnflksjhtf+p1q";

const constructionBase = "http://localhost:7001";
const constructionLoginUrl = "$constructionBase/api/login";
const clientId = "cd6c1f57-72be-4b8f-8fb1-eb1889624e08";

final oauth = OAuth(apiToken: apiToken, clientID: clientId, loginUrl: constructionLoginUrl);
final mln = Mln(
  oauth: oauth,
  encryptionKey: flashKey,
  validAwards: validAwards,
);
