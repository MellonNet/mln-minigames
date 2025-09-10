import "dart:io";

import "package:xml/xml.dart";

import "package:mln_shared/data.dart";
import "package:mln_shared/utils.dart";

import "service.dart";

class Editorial extends Service {
  static final file = File("editorial.xml");

  late final XmlDocument xml;
  late final List<ItemInfo> items;

  @override
  Future<void> init() async {
    final contents = await file.readAsString();
    xml = XmlDocument.parse(contents);
    final itemRoot = xml.rootElement.getElement("items")!;
    items = itemRoot.childElements.map(ItemInfo.fromXml).toList();
  }

  Iterable<ItemInfo> searchItems(String query, {bool blueprints = false}) => items
    .where((item) => item.matches(query))
    .where((item) => blueprints || !item.name.containsInsensitive("blueprint"));

  Uri? getThumbnail(String itemName) => searchItems(itemName, blueprints: true)
    .first
    .thumbnailUrl
    .toUri();
}

extension on String {
  Uri toUri() => Uri.parse(this);
}
