import "dart:io";

import "package:mln_bot/secrets.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";

import "package:mln_shared/mln_shared.dart";

class MlnServer {
  static const host = "localhost:7002";
  static const loginPath = "/api/login";
  static const loginUrl = "http://$host$loginPath";

  static final sessionsFile = File("sessions.txt");
  static Future<void> saveToFile(SessionID sessionID, AccessToken accessToken) async {
    final line = "$sessionID=$accessToken\n";
    await sessionsFile.writeAsString(line, mode: FileMode.append);
  }

  final oauth = OAuth(
    apiToken: mlnApiToken,
    clientID: mlnClientID,
    loginUrl: loginUrl,
    loginCallback: saveToFile,
  );

  HttpServer? _server;

  Uri getLoginUrl() => oauth.getLoginUri(OAuth.getSessionID());

  void dispose() => _server?.close();

  Future<void> init() async {
    if (!sessionsFile.existsSync()) return;
    for (final line in await sessionsFile.readAsLines()) {
      if (line.isEmpty) continue;
      final [session, access] = line.split("=");
      final sessionID = SessionID(session);
      final accessToken = AccessToken(access);
      oauth.sessionToTokens[sessionID] = accessToken;
    }
  }

  Future<void> serve() async {
    final app = Router();
    app.get(loginPath, oauthHandler(oauth));

    final server = await io.serve(app.call, "localhost", 7002);
    print("Serving on http://localhost:${server.port}");
  }
}

final server = MlnServer();
