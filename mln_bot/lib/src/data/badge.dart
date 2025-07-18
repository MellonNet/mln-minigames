import "utils.dart";

class Badge {
  final int id;
  final String name;

  Badge.fromJson(Json json) :
    id = json["id"],
    name = json["name"];
}
