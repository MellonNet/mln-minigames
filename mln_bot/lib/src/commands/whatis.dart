import "package:collection/collection.dart";
import "package:mln_bot/data.dart";
import "package:mln_bot/services.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "utils.dart";

final itemQuery = ChatCommand(
  "what-is",
  "Gets information about an item or module",
  itemQueryAction,
);

final itemQueryPublic = ChatCommand(
  "explain",
  "Gets information about an item or module and sends it to the chat",
  itemQueryAction,
  options: const CommandOptions(
    defaultResponseLevel: ResponseLevel.public,
  ),
);

Future<void> itemQueryAction(ChatContext context, [String? query]) async {
  if (query == null) {
    await context.respondText("Please tell me what item you want to see");
    return;
  }

  final items = services.editorial.searchItems(query).toList();
  if (items.isEmpty) {
    return context.respondText("Could not find any items or modules with that name.\n\nIf you tried to search for a blueprint, try searching the item or module it produces instead");
  } else if (items.length > 1) {
    final exactMatch = items.firstWhereOrNull((item) => item.name.caseInsensitive(query));
    if (exactMatch != null) {
      final message = await getMessage(exactMatch);
      return context.respondText(message);
    }
    final buffer = StringBuffer();
    buffer.writeln("Found multiple items with that name, please try again with a more specific query");
    buffer.writeln();
    for (final item in items) {
      buffer.writeln("- ${item.name}");
    }
    final message = buffer.toString();
    return context.respondText(message);
  } else {
    final item = items.first;
    final message = await getMessage(item);
    return context.respondText(message);
  }
}

Future<String> getMessage(ItemInfo item) async {
  final wikiItem = await services.wiki.getItem(item);
  final buffer = StringBuffer();
  buffer.writeln("Sure! Sure! Here's what I know about ${item.name}:");
  buffer.writeln();
  buffer.writeln(item.description);
  buffer.writeln();
  if (wikiItem != null) {
    buffer.writeln("Here's what I found on the wiki: ");
    buffer.writeln("- How to obtain: ${wikiItem.howToObtain}");
    buffer.writeln("- Cost to build: ${wikiItem.costToBuild}");
  } else {
    buffer.writeln("I couldn't find any information about that on the wiki.");
  }
  return buffer.toString();
}
