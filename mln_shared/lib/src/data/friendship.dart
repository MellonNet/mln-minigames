import "package:mln_shared/utils.dart";

enum FriendshipStatus {
  none,
  friend,
  pending,
  blocked;

  static FriendshipStatus? fromJson(String? json) =>
    json == null ? null : values.byName(json);

  String get describe => switch(this) {
    none => "Is not your friend",
    friend => "Is your friend",
    pending => "You've sent them a friend request",
    blocked => "Is blocked",
  };
}

class Friendship {
  final String from;
  final String to;
  final FriendshipStatus status;
  final String? action;

  Friendship.fromJson(Json json) :
    from = json["from_username"],
    to = json["to_username"],
    status = FriendshipStatus.fromJson(json["status"])!,
    action = json["action"];

  String getOther(String username) =>
    from == username ? to : from;

  String describeText(String username) => switch (status) {
    FriendshipStatus.none => "${getOther(username)} removed you as a friend 😟",
    FriendshipStatus.friend => "${getOther(username)} accepted your request!",
    FriendshipStatus.pending => "${getOther(username)} sent you a friend request!",
    FriendshipStatus.blocked => "${getOther(username)} blocked you... did you say something mean?",
  };
}
