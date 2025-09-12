import "package:collection/collection.dart";
import "package:mln_bot/secrets.dart";
import "package:mln_bot/services.dart";
import "package:nyxx/nyxx.dart";

import "package:mln_shared/mln_shared.dart" hide User;

sealed class MessageFollowUp { }

class MessageReply extends MessageFollowUp {
  final String message;
  final bool replace;
  MessageReply(this.message, {this.replace = false});
}

class MessageReaction extends MessageFollowUp {
  final String emoji;
  MessageReaction(this.emoji);
  MessageReaction.thumbsUp() : emoji = "👍";
}

class MessageDelete extends MessageFollowUp { }

extension DiscordUtils on NyxxGateway {
  Future<void> replyTo(InteractionCreateEvent event, MessageBuilder? builder) => interactions
    .createResponse(
      event.interaction.id,
      event.interaction.token,
      builder == null
        ? InteractionResponseBuilder.deferredUpdateMessage()
        : InteractionResponseBuilder.channelMessage(builder),
      withResponse: true,
    );

  Future<void> edit(InteractionCreateEvent event, MessageUpdateBuilder builder) => interactions
    .createResponse(
      event.interaction.id,
      event.interaction.token,
      InteractionResponseBuilder.updateMessage(builder),
    );

  Future<void> replyToString(InteractionCreateEvent<Interaction<dynamic>> event, String message) async {
    final builder = MessageBuilder(flags: MessageFlags.ephemeral, content: message);
    return replyTo(event, builder);
  }

  Future<void> followUp<T>(
    InteractionCreateEvent<Interaction<dynamic>> event, {
    required Future<T?> Function() func,
    required MessageFollowUp Function(T) followUp,
  }) async {
    try {
      final result = await func();
      if (result == null || result == false) {
        return replyToString(event, "An error occurred");
      }
      switch (followUp(result)) {
        case MessageReply(:final message, :final replace):
          if (replace) await event.interaction.message?.delete();
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
    } catch (error, stack) {
      print(error);
      print(stack);
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

  Future<void> createRoles({
    required Iterable<String> names,
    required DiscordColor color,
    required bool isHoisted,
  }) async {
    const serverID = Snowflake(botServerID);
    final server = await guilds.get(serverID);
    final roles = server.roleList;
    for (final name in names) {
      if (roles.any((role) => role.name == name)) continue;
      final builder = RoleBuilder(
        name: name,
        isHoisted: isHoisted,
        isMentionable: true,
        color: color,
      );
      await server.roles.create(builder);
    }
  }
}

extension PartialRolesUtils on List<PartialRole> {
  bool containsRole(Role otherRole) =>
    any((role) => role.id == otherRole.id);
}

extension RolesUtils on List<Role> {
  Role? findRole(String name) => firstWhereOrNull((role) => role.name == name);
}

extension InteractionUtils on InteractionCreateEvent {
  User? get discordUser => interaction.user ?? interaction.member?.user;

  MlnClient? get mlnClient {
    final userID = discordUser?.id;
    if (userID == null) return null;
    final session = services.cache.sessionsByDiscord[userID];
    return session?.client;
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

  Future<bool> isOriginalUser() async {
    final originalMessage = await message.get();
    final originalInteraction = originalMessage.interactionMetadata;
    final originalUser = originalInteraction?.user;
    return user.id == originalUser?.id;
  }
}
