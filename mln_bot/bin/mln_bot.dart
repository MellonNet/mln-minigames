import "package:mln_bot/services.dart";

void main(List<String> args) async {
  Services.debug = args.contains("--debug") || args.contains("-d");
  await services.init();
}
