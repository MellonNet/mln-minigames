import "package:mln_shared/utils.dart";
import "package:mln_shared/clients.dart";

import "badge.dart";
import "friendship.dart";

class User {
  final String username;
  final String pagePath;
  final int rank;
  final bool isNetworker;
  final FriendshipStatus friendshipStatus;
  final List<Badge> badges;

  User.fromJson(Json json) :
    username = json["username"],
    pagePath = json["page_url"],
    rank = json["rank"],
    isNetworker = json["is_networker"],
    friendshipStatus = FriendshipStatus.fromJson(json["friendship_status"]),
    badges = [
      for (final badgeJson in json["badges"])
        Badge.fromJson(Json.from(badgeJson)),
    ];

  static Uri pageUrl(String username) =>
    Uri.parse("${MlnClient.host}/mln/public_view/$username");
}
