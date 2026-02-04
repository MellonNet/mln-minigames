import "package:collection/collection.dart";

import "utils.dart";

final itemQuery = ChatCommand(
  "what-is",
  "Gets information about an item or module",
  id("what-is", itemQueryAction),
);

final itemQueryPublic = ChatCommand(
  "explain",
  "Gets information about an item or module and sends it to the chat",
  id("what-is-public", itemQueryAction),
  options: const CommandOptions(
    defaultResponseLevel: ResponseLevel.public,
  ),
);

Future<void> itemQueryAction(
  ChatContext context,
  @Description("The item or module to describe")
  String query
) async {
  final isPublic = context.command.name == "explain";
  final items = services.editorial.searchItems(query).toList();
  if (items.isEmpty) {
    return context.respondText("Could not find any items or modules that match: $query.\n\nIf you tried to search for a blueprint, try searching the item or module it produces instead");
  } else if (items.length > 1) {
    final exactMatch = items.firstWhereOrNull((item) => item.name.caseInsensitive(query));
    if (exactMatch != null) return context.respondItem(exactMatch, isPublic: isPublic);
    await context.respondItems(items, isPublic: isPublic);
  } else {
    final item = items.first;
    await context.respondItem(item, isPublic: isPublic);
  }
}
