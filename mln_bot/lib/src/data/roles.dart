import "package:nyxx/nyxx.dart";

const miniRankChoices = {
  "The Robot Chronicles": "The Robot Chronicles",
  "Star Justice": "Star Justice",
  "LEGO Universe": "LEGO Universe",
  "Bionicle": "Bionicle",
};

Iterable<String> get miniRankRoles => miniRankChoices.keys;

const miniRankColor = DiscordColor.fromRgb(231, 76, 60);

final rankRoles = <String>[
  for (var rank = 0; rank < 11; rank++)
    "Rank $rank",
];

const rankColor = DiscordColor.fromRgb(255, 0, 238);
