import "package:mln_bot/services.dart";

void main(List<String> args) async {
  // Open OAuth server
  final editorial = Editorial();
  await editorial.init();

  final items = editorial.searchItems(args.first);
  print("");

  final item = items.firstOrNull;
  if (item != null) { 
    print(item.describe());
    final wiki = await services.wiki.getItem(item);
    print("To obtain: ${wiki?.howToObtain}");
    print("To build: ${wiki?.costToBuild}");
    services.wiki.dispose();
  }
}
