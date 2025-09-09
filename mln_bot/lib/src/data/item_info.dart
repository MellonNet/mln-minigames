import "package:mln_shared/clients.dart";
import "package:xml/xml.dart";

import "utils.dart";

extension type ItemID(String value) { }
class ItemInfo {
  final String name;
  final String description;
  final ItemID id;
  final String thumbnailPath;

  ItemInfo.fromXml(XmlElement element) : 
    name = element.getAttribute("name")!,
    description = element.getAttribute("description")!,
    id = ItemID(element.getAttribute("id")!),
    thumbnailPath = element.getAttribute("thumbnail")!;

  String get thumbnailUrl => "${MlnClient.host}$thumbnailPath";

  @override
  String toString() => name;

  bool matches(String query) => name.fuzzyMatch(query);
}
