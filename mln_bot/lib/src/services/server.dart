import "dart:async";
import "dart:convert";
import "dart:io";

import "package:nyxx/nyxx.dart" as nyxx;
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

  static const badgesWebhookPath = "/api/badges";
  static const rankUpWebhookPath = "/api/rank_up";

  final OAuth oauth = OAuth(
    apiToken: mlnApiToken,
    clientID: mlnClientID,
    loginCallback: (sessionID, accessToken) async {
      await services.cache.saveSession(sessionID, accessToken);
      await services.discord.grantRoleLogin(accessToken);
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
    app.post(badgesWebhookPath, authMiddleware(_handleBadgesWebhook));
    app.post(rankUpWebhookPath, authMiddleware(_handleRankUpWebhook));

    final server = await io.serve(app.call, "0.0.0.0", 9005);
    print("Serving on 0.0.0.0:${server.port}");
  }

  Future<Response> _handleMessageWebhook(Request request) async {
    // Get the associated Discord user for this message
    final session = request.session;
    if (session == null) return Response.ok(null);

    // Send the message to the Discord user
    final json = await request.json();
    final message = Message.fromJson(json);
    final discordMessage = message.describe();
    await services.discord.sendMessage(session.discordID, discordMessage);

    // The MLN server does not care about this response
    return Response.ok(null);
  }

  Future<Response> _handleFriendWebhook(Request request) async {
    // Get the associated Discord user for this webhook
    final session = request.session;
    if (session == null) return Response.ok(null);

    // Send a message to the user about their new friendship
    final json = await request.json();
    final friendship = Friendship.fromJson(json);
    final message = friendship.describe(session.mlnUsername);
    await services.discord.sendMessage(session.discordID, message);

    // The MLN server does not care about this response
    return Response.ok(null);
  }

  FutureOr<Response> _handleBadgesWebhook(Request request) async {
    final json = await request.json();
    final username = json["username"] as String;
    final badge = json["badge"] as String;
    final text = "${UserUtils.userLink(username)} just got the $badge!";
    final button = nyxx.ButtonBuilder.primary(customId: "friend-add_$username", label: "Send friend request");
    final builder = buildButton(text, button, isPublic: true);
    await services.discord.sendToBotChannel(builder);
    return Response.ok(null);
  }

  FutureOr<Response> _handleRankUpWebhook(Request request) async {
    final json = await request.json();
    final username = json["username"] as String;
    final rank = json["rank"] as int;
    final text = "${UserUtils.userLink(username)} just got to Rank $rank! Keep it up!";
    final button = nyxx.ButtonBuilder.primary(customId: "friend-add_$username", label: "Send friend request");
    final builder = buildButton(text, button, isPublic: true);
    await services.discord.sendToBotChannel(builder);

    // Update the user's role if they're signed into the MellonBot
    final session = services.cache.sessionsByMlnUsername[username];
    if (session != null) {
      await services.discord.grantRankRole(session.discordID, rank);
    }

    return Response.ok(null);
  }
}

Handler authMiddleware(Handler innerHandler) => (Request request) {
  final apiToken = request.headers["Api-Token"];
  if (apiToken != mlnWebhookApiToken) return Response.unauthorized(null);
  return innerHandler(request);
};

extension on Request {
  MellonBotSession? get session {
    final authHeader = headers[HttpHeaders.authorizationHeader];
    if (authHeader == null) return null;
    final [_, token] = authHeader.split(" ");  // "Bearer TOKEN"
    final accessToken = AccessToken(token);
    return services.cache.sessionsByAccessToken[accessToken];
  }

  Future<Json> json() async => jsonDecode(await readAsString());
}
