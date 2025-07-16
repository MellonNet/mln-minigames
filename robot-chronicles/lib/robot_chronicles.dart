import "package:mln_shared/mln_shared.dart";

import "secrets.dart";

const validAwards = {1, 2, 3, 4, 5};
const key = "13bv9cyruhnflksjhtf+p1q";

// This is a public, non-secret identifier for the OAuth login page.
const clientID = "8203164e-4cd0-48ce-833d-2a9cefe3f8b8";
const robotChroniclesBase = "http://localhost:7000";
const loginUrl = "$robotChroniclesBase/api/login";

final oauth = OAuth(
  apiToken: apiToken,  // from secrets.dart
  clientID: clientID,
  loginUrl: loginUrl,
);

final mln = Mln(
  oauth: oauth,
  encryptionKey: key,
  validAwards: validAwards,
);
