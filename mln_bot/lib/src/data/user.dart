import "badge.dart";
import "friendship.dart";
import "utils.dart";

class User {
  final String username;
  final String pageUrl;
  final int rank;
  final bool isNetworker;
  final FriendshipStatus friendshipStatus;
  final List<Badge> badges;

  User.fromJson(Json json) :
    username = json["username"],
    pageUrl = json["page_url"],
    rank = json["rank"],
    isNetworker = json["is_networker"],
    friendshipStatus = FriendshipStatus.fromJson(json["friendship_status"]),
    badges = [
      for (final badgeJson in json["badges"])
        Badge.fromJson(Json.from(badgeJson)),
    ];
}
