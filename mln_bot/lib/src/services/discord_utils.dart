import "dart:io";

import "package:mln_bot/services.dart";
import "package:nyxx/nyxx.dart";

import "package:mln_shared/mln_shared.dart" hide User;

extension DiscordUtils on NyxxGateway {
  Future<void> replyTo(InteractionCreateEvent<Interaction<dynamic>> event, MessageBuilder builder) async {
    await interactions.createResponse(
      event.interaction.id,
      event.interaction.token,
      InteractionResponseBuilder.channelMessage(builder),
      withResponse: true,
    );
  }

  Future<void> replyToString(InteractionCreateEvent<Interaction<dynamic>> event, String message) async {
    final builder = MessageBuilder(flags: MessageFlags.ephemeral, content: message);
    return replyTo(event, builder);
  }

  Future<void> followUp(
    InteractionCreateEvent<Interaction<dynamic>> event, {
    required Future<void> Function() func,
    required String? message,
    bool react = false,
  }) async {
    try {
      await func();
      if (message != null) {
        await replyToString(event, message);
      }
      if (react) {
        await event.interaction.message?.react(ReactionBuilder(name: "👍", id: null));
      }
    } on ApiException catch (error) {
      await replyToString(event, error.message);
    // Catch all errors
    // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      await replyToString(event, "An error occurred");
    }
  }

  void setStatus() => updatePresence(
    PresenceBuilder(
      activities: [
        if (Platform.isLinux)
          ActivityBuilder(
            type: ActivityType.game,
            name: "My Lego Network",
            state: "Baking an Apple Pie",
            url: Uri.parse("https://mln.mellonnet.com"),
          )
        else
          ActivityBuilder(
            name: "Maintenance",
            state: "Undergoing Maintenance",
            type: ActivityType.custom,
          )
      ],
      status: Platform.isLinux ? CurrentUserStatus.online : CurrentUserStatus.dnd,
      isAfk: false,
      since: DateTime.now(),
    ),
  );
}

extension InteractionUtils on InteractionCreateEvent {
  AccessToken? get mlnAccessToken {
    final user = interaction.user;
    if (user == null) return null;
    final sessionID = services.cache.discordToMln(user.id);
    return services.cache.sessionToToken[sessionID];
  }
}
