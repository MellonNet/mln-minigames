import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";
import "package:shelf_static/shelf_static.dart";

import "package:mln_shared/mln_shared.dart";
import "package:robot_chronicles/robot_chronicles.dart";

void main() async {
  final app = Router();
  app.get("/", (_) => Response.found("/TheRobotChronicles.swf"));
  app.post("/undefined/ExecuteAwardgiver", handleAwards);
  app.get("/api/login", loginHandler);

  final staticHandler = createStaticHandler("static");
  final handler = buildServer(apiHandler: app.call, staticHandler: staticHandler);
  final server = await io.serve(handler, "localhost", 7000);
  print("Serving on http://localhost:${server.port}");
}
