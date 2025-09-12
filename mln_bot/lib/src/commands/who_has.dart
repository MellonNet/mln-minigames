import "package:collection/collection.dart";

import "utils.dart";

final whoHasCommand = ChatCommand(
  "who-has",
  "Finds a random user who has a certain module",
  _whoHas,
);

Future<void> _whoHas(
  ChatContext context,
  @Description("The module to find")
  String query
) async {
  final items = services.editorial.searchItems(query, type: "module").toList();
  if (items.isEmpty) {
    return context.respondText("Could not find any modules that match: $query");
  } else if (items.length > 1) {
    final exactMatch = items.firstWhereOrNull((item) => item.name.caseInsensitive(query));
    if (exactMatch != null) return _respondWhoHas(context, exactMatch);
    await context.respondModules(items);
  } else {
    await _respondWhoHas(context, items.first);
  }
}

Future<void> _respondWhoHas(ChatContext context, ItemInfo module) => context.handle(
  func: () => context.getAnyClient().whoHas(module),
  onSuccess: (users) {
    final (ready, notReady) = users;
    final builder = pickPreferredUser(module, ready, notReady);
    context.respond(builder);
  }
);
