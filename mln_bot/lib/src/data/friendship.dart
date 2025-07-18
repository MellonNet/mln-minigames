enum FriendshipStatus {
  none,
  friend,
  pending,
  blocked;

  factory FriendshipStatus.fromJson(String json) => values.byName(json);

  String get describe => switch(this) {
    none => "Is not your friend",
    friend => "Is your friend",
    pending => "You've sent them a friend request",
    blocked => "Is blocked",
  };
}
