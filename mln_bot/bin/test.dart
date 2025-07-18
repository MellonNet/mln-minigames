import "package:mln_bot/clients.dart";
// import 'package:mln_bot/server.dart';
import "package:mln_shared/mln_shared.dart";

void main() async {
  // final server = MlnServer();
  // await server.serve();
  // final sessionID = OAuth.getSessionID();
  // print(server.oauth.getLoginUri(sessionID));

  final accessToken = AccessToken("4xeCzNnSfvPg3jzNOyIRHw2kHQGlhHwJPzQbvKZOcT4");
  final client = MlnClient(accessToken);
  final user = await client.getUser("dudeface3175").handle((user) => user.describe());
  print(user);
  client.dispose();
}
