import "package:collection/collection.dart";
import "package:html/dom.dart";
import "package:http/http.dart";
import "package:html/parser.dart";
import "package:mln_bot/data.dart";
import "package:mln_shared/mln_shared.dart";

import "service.dart";

class WikiItem {
  final String howToObtain;
  final String costToBuild;
  WikiItem({
    required this.costToBuild,
    required this.howToObtain,
  });
}

extension on Element {
  String get rowHeader => children.first.text.trim();
  String get rowText => children[1].text.trim();
}

class Wiki extends Service {
  final client = Client();
  
  @override
  Future<void> init() async { }

  void dispose() => client.close();

  Uri buildUriItem(ItemInfo item) =>
    Uri.parse("https://mylegonetwork.fandom.com/wiki/${item.name.replaceAll(" ", "_")}") ;

  Future<WikiItem?> getItem(ItemInfo item) async {
    final uri = buildUriItem(item);
    final response = await client.get(uri).ignoreAllErrors();
    if (response == null || response.statusCode != 200) return null;
    final html = parse(response.body);
    final sidebar = html.getElementById("content")
      ?.getElementsByTagName("tbody").firstOrNull;
    if (sidebar == null) return null;
    final rows = sidebar.children;
    final howToObtain = rows
      .firstWhereOrNull((row) => row.rowHeader == "How to Obtain")
      ?.rowText;
    final costToBuild = rows
      .firstWhereOrNull((row) => row.rowHeader == "Cost to Build")
      ?.rowText;
    if (howToObtain == null || costToBuild == null) return null;
    return WikiItem(costToBuild: costToBuild, howToObtain: howToObtain);
  }
}
