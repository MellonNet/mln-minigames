import "package:mln_bot/services.dart";

void main(List<String> args) async {
  Services.debugFlag = args.contains("--debug") || args.contains("-d");
  await services.init();
}
