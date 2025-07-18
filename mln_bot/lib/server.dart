import "dart:io";

import "package:mln_bot/secrets.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";

import "package:mln_shared/mln_shared.dart";
import "cache.dart";

class MlnServer {
  static const host = "localhost:7002";
  static const loginPath = "/api/login";
  static const loginUrl = "http://$host$loginPath";

  final OAuth oauth = OAuth(
    apiToken: mlnApiToken,
    clientID: mlnClientID,
    loginUrl: loginUrl,
    loginCallback: (sessionID, accessToken) async {
      await cache.saveAccessTokens();
    }
  );

  HttpServer? _server;

  void dispose() => _server?.close();

  Future<void> serve() async {
    final app = Router();
    app.get(loginPath, oauthHandler(oauth));

    final server = await io.serve(app.call, "localhost", 7002);
    print("Serving on http://localhost:${server.port}");
  }
}

final server = MlnServer();
