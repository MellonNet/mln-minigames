import "package:mln_bot/services.dart";

void main() async {
  // Open OAuth server
  final editorial = Editorial();
  await editorial.init();

  final items = editorial.searchItems("bee bat module 1");
  print("Found ${items.length} items:");
  for (final item in items) {
    print("- $item");
  }

  print("");

  print(items.first.describe());
}
