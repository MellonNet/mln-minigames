import "dart:convert";
import "dart:io";

import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";

import "package:mln_shared/mln_shared.dart" hide RequestUtils;
import "package:mln_bot/clients.dart";
import "package:mln_bot/data.dart";
import "package:mln_bot/secrets.dart";

import "cache.dart";

class MlnServer {
  static const host = "localhost:7002";
  static const loginPath = "/api/login";
  static const loginUrl = "http://$host$loginPath";
  static const messagesWebhookPath = "/api/message";
  static const messagesWebhookUrl = "http://$host$messagesWebhookPath";

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
    app.post(messagesWebhookPath, authMiddleware(_handleMessageWebhook));

    final server = await io.serve(app.call, "localhost", 7002);
    print("Serving on http://localhost:${server.port}");
  }

  Future<Response> _handleMessageWebhook(Request request) async {
    // Get the associated Discord user for this message
    final sessionID = request.sessionID;
    if (sessionID == null) return Response.ok(null);
    final discordUser = cache.sessionToDiscord[sessionID];
    if (discordUser == null) return Response.ok(null);

    final body = await request.readAsString();
    final data = jsonDecode(body);
    final message = Message.fromJson(data);
    final discordMessage = message.describe();
    await discordClient.sendMessage(discordUser, discordMessage);

    // The MLN server does not care about this response
    return Response.ok(null);
  }
}

Handler authMiddleware(Handler innerHandler) => (Request request) {
  final apiToken = request.headers["Api-Token"];
  if (apiToken != mlnWebhookApiToken) return Response.unauthorized(null);
  return innerHandler(request);
};

extension on Request {
  SessionID? get sessionID {
    final authHeader = headers[HttpHeaders.authorizationHeader]!;
    final [_, token] = authHeader.split(" ");  // "Bearer TOKEN"
    final accessToken = AccessToken(token);
    return cache.tokenToSession[accessToken];
  }
}

final server = MlnServer();
