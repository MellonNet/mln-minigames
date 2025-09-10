import "package:mln_shared/utils.dart";
import "package:mln_shared/clients.dart";

import "badge.dart";
import "friendship.dart";

T? _parse<T, J>(T Function(J) fromJson, J? json) =>
  json == null ? null : fromJson(json);

class User {
  final String username;
  final String pagePath;
  final int rank;
  final bool isNetworker;
  final FriendshipStatus? friendshipStatus;
  final List<Badge> badges;

  User.fromJson(Json json) :
    username = json["username"],
    pagePath = json["page_url"],
    rank = json["rank"],
    isNetworker = json["is_networker"],
    friendshipStatus = _parse(FriendshipStatus.fromJson, json["friendship_status"] as String?),
    badges = [
      for (final badgeJson in json["badges"])
        Badge.fromJson(Json.from(badgeJson)),
    ];

  static Uri pageUrl(String username) =>
    Uri.parse("${MlnClient.host}/mln/public_view/$username");
}
