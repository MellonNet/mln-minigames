import "dart:convert";
import "dart:io";

import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";

import "package:mln_shared/mln_shared.dart";
import "package:mln_bot/data.dart";
import "package:mln_bot/secrets.dart";

import "package:mln_bot/services.dart";

class MlnServer extends Service {
  static const messagesWebhookPath = "/api/message";
  static const messagesWebhookUrl = "https://discord-bot.mellonnet.com$messagesWebhookPath";

  static const friendsWebhookPath = "/api/friends";
  static const friendsWebhookUrl = "https://discord-bot.mellonnet.com$friendsWebhookPath";

  final OAuth oauth = OAuth(
    apiToken: mlnApiToken,
    clientID: mlnClientID,
    loginCallback: (sessionID, accessToken) async {
      await services.cache.saveAccessTokens();
    }
  );

  HttpServer? _server;

  void dispose() => _server?.close();

  @override
  Future<void> init() async {
    final app = Router();
    app.get("/api/login", loginHandler(oauth));
    app.post(messagesWebhookPath, authMiddleware(_handleMessageWebhook));
    app.post(friendsWebhookPath, authMiddleware(_handleFriendWebhook));

    final server = await io.serve(app.call, "0.0.0.0", 9005);
    print("Serving on 0.0.0.0:${server.port}");
  }

  Future<Response> _handleMessageWebhook(Request request) async {
    // Get the associated Discord user for this message
    final accessToken = request.accessToken;
    if (accessToken == null) return Response.ok(null);
    final sessionID = services.cache.tokenToSession[accessToken];
    if (sessionID == null) return Response.ok(null);
    final discordUser = services.cache.sessionToDiscord[sessionID];
    if (discordUser == null) return Response.ok(null);

    final body = await request.readAsString();
    final data = jsonDecode(body);
    final message = Message.fromJson(data);
    final discordMessage = message.describe();
    await services.discord.sendMessage(discordUser, discordMessage);

    // The MLN server does not care about this response
    return Response.ok(null);
  }

  Future<Response> _handleFriendWebhook(Request request) async {
    // Get the associated Discord user for this webhook
    final accessToken = request.accessToken;
    if (accessToken == null) return Response.ok(null);
    final sessionID = services.cache.tokenToSession[accessToken];
    if (sessionID == null) return Response.ok(null);
    final discordUser = services.cache.sessionToDiscord[sessionID];
    if (discordUser == null) return Response.ok(null);
    final client = MlnClient(accessToken, mlnApiToken);
    final user = await client.whoAmI();
    if (user == null) return Response.ok(null);

    final body = await request.readAsString();
    final data = jsonDecode(body);
    final friendship = Friendship.fromJson(data);
    final message = friendship.describe(user.username);
    await services.discord.sendMessage(discordUser, message);

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
  AccessToken get accessToken {
    final authHeader = headers[HttpHeaders.authorizationHeader]!;
    final [_, token] = authHeader.split(" ");  // "Bearer TOKEN"
    final accessToken = AccessToken(token);
    return accessToken;
  }
}
