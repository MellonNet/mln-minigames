export "src/services/cache.dart";
export "src/services/discord.dart";
export "src/services/editorial.dart";
export "src/services/server.dart";
export "src/services/service.dart";
export "src/services/wiki.dart";

import "dart:io";

import "";

class Services extends Service {
  static bool debugFlag = false;
  static bool get debug => !Platform.isLinux || debugFlag;

  final cache = Cache();
  final editorial = Editorial();
  final server = MlnServer();
  final wiki = Wiki();
  final discord = DiscordClient();

  List<Service> get services => [cache, editorial, server, wiki, discord];

  @override
  Future<void> init() async {
    for (final service in services) {
      await service.init();
    }
  }
}

final services = Services();
