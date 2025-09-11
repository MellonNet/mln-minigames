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
    app.post(badgesWebhookPath, authMiddleware(_handleBadgesWebhook));
    app.post(rankUpWebhookPath, authMiddleware(_handleRankUpWebhook));

    final server = await io.serve(app.call, "0.0.0.0", 9005);
    print("Serving on 0.0.0.0:${server.port}");
  }

  Future<Response> _handleMessageWebhook(Request request) async {
    // Get the associated Discord user for this message
    final user = request.user;
    if (user == null) return Response.ok(null);
    final (accessToken, discordUser) = user;

    // Send the message to the Discord user
    final json = await request.json();
    final message = Message.fromJson(json);
    final discordMessage = message.describe();
    await services.discord.sendMessage(discordUser, discordMessage);

    // The MLN server does not care about this response
    return Response.ok(null);
  }

  Future<Response> _handleFriendWebhook(Request request) async {
    // Get the associated Discord user for this webhook
    final webhookUser = request.user;
    if (webhookUser == null) return Response.ok(null);
    final (accessToken, discordUser) = webhookUser;

    // Get the MLN user and their details
    final client = MlnClient(accessToken, mlnApiToken);
    final user = await client.whoAmI();
    if (user == null) return Response.ok(null);

    // Send a message to the user about their new friendship
    final json = await request.json();
    final friendship = Friendship.fromJson(json);
    final message = friendship.describe(user.username);
    await services.discord.sendMessage(discordUser, message);

    // The MLN server does not care about this response
    return Response.ok(null);
  }

  FutureOr<Response> _handleBadgesWebhook(Request request) async {
    final json = await request.json();
    final username = json["username"] as String;
    final badge = json["badge"] as String;
    final text = "${UserUtils.userLink(username)} just got the $badge!";
    final button = nyxx.ButtonBuilder.primary(customId: "friend-add_$username", label: "Send friend request");
    final builder = buildButton(text, button);
    await services.discord.sendToBotChannel(builder);
    return Response.ok(null);
  }

  FutureOr<Response> _handleRankUpWebhook(Request request) async {
    final json = await request.json();
    final username = json["username"] as String;
    final rank = json["rank"] as int;
    final text = "${UserUtils.userLink(username)} just got to Rank $rank! Keep it up!";
    final button = nyxx.ButtonBuilder.primary(customId: "friend-add_$username", label: "Send friend request");
    final builder = buildButton(text, button);
    await services.discord.sendToBotChannel(builder);
    return Response.ok(null);
  }
}

Handler authMiddleware(Handler innerHandler) => (Request request) {
  final apiToken = request.headers["Api-Token"];
  if (apiToken != mlnWebhookApiToken) return Response.unauthorized(null);
  return innerHandler(request);
};

extension on Request {
  (AccessToken, nyxx.Snowflake)? get user {
    final authHeader = headers[HttpHeaders.authorizationHeader];
    if (authHeader == null) return null;
    final [_, token] = authHeader.split(" ");  // "Bearer TOKEN"
    final accessToken = AccessToken(token);
    final sessionID = services.cache.tokenToSession[accessToken];
    if (sessionID == null) return null;
    final snowflake = services.cache.sessionToDiscord[sessionID];
    if (snowflake == null) return null;
    return (accessToken, snowflake);
  }

  Future<Json> json() async => jsonDecode(await readAsString());
}
