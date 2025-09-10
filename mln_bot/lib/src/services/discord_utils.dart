import "package:collection/collection.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_bot/services.dart";
import "package:nyxx/nyxx.dart";

import "package:mln_shared/mln_shared.dart" hide User;

sealed class MessageFollowUp { }

class MessageReply extends MessageFollowUp {
  final String message;
  MessageReply(this.message);
}

class MessageReaction extends MessageFollowUp {
  final String emoji;
  MessageReaction(this.emoji);
  MessageReaction.thumbsUp() : emoji = "👍";
}

class MessageDelete extends MessageFollowUp { }

extension DiscordUtils on NyxxGateway {
  Future<void> replyTo(InteractionCreateEvent<Interaction<dynamic>> event, MessageBuilder? builder) async {
    await interactions.createResponse(
      event.interaction.id,
      event.interaction.token,
      builder == null
        ? InteractionResponseBuilder.deferredUpdateMessage()
        : InteractionResponseBuilder.channelMessage(builder),
      withResponse: true,
    );
  }

  Future<void> replyToString(InteractionCreateEvent<Interaction<dynamic>> event, String message) async {
    final builder = MessageBuilder(flags: MessageFlags.ephemeral, content: message);
    return replyTo(event, builder);
  }

  Future<void> followUp<T>(
    InteractionCreateEvent<Interaction<dynamic>> event, {
    required Future<T?> Function() func,
    required MessageFollowUp Function(T) followUp,
    // required String? message,
    // bool react = false,
    // bool delete = false,
  }) async {
    try {
      final result = await func();
      if (result == null) return replyToString(event, "An error occurred");
      switch (followUp(result)) {
        case MessageReply(:final message):
          await replyToString(event, message);
        case MessageReaction(:final emoji):
          await event.interaction.message?.react(ReactionBuilder(name: emoji, id: null));
          await replyTo(event, null);
        case MessageDelete():
          await event.interaction.message?.delete();
          await replyTo(event, null);
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
        if (Services.debug)
          ActivityBuilder(
            name: "Maintenance",
            state: "Undergoing Maintenance",
            type: ActivityType.custom,
          )
        else
          ActivityBuilder(
            type: ActivityType.game,
            name: "My Lego Network",
            state: "Baking an Apple Pie",
            url: Uri.parse("https://mln.mellonnet.com"),
          )
      ],
      status: Services.debug
        ? CurrentUserStatus.dnd : CurrentUserStatus.online,
      isAfk: false,
      since: DateTime.now(),
    ),
  );
}

extension InteractionUtils on InteractionCreateEvent {
  MlnClient? get mlnClient {
    final user = interaction.user;
    if (user == null) return null;
    final sessionID = services.cache.discordToMln(user.id);
    final accessToken = services.cache.sessionToToken[sessionID];
    if (accessToken == null) return null;
    return MlnClient(accessToken, mlnApiToken);
  }
}

extension MessageReactionAddEventUtils on MessageReactionAddEvent {
  Future<bool> hasRole(String roleName) async {
    final allRoles = await guild?.roles.list();
    final roleID = allRoles
      ?.firstWhereOrNull((role) => role.name == roleName)
      ?.id;
    return member?.roles.any((role) => role.id == roleID) ?? false;
  }

  Future<bool> isDm() async => (await message.channel.get())
    .type == ChannelType.dm;
}
