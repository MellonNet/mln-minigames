enum FriendshipStatus {
  none,
  friend,
  pending,
  blocked;

  factory FriendshipStatus.fromJson(String json) => values.byName(json);
}
