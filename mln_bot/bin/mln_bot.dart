import "package:mln_bot/cache.dart";
import "package:mln_bot/server.dart";
import "package:mln_bot/clients.dart";

void main() async {
  // Open OAuth server
  await cache.init();
  await server.serve();
  await discordClient.init();
}
