import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;
import "package:shelf_router/shelf_router.dart";
import "package:shelf_static/shelf_static.dart";

import "package:mln_shared/mln_shared.dart";
import "package:construction/construction.dart";

void main() async {
  final app = Router();
  app.get("/", (_) => Response.found("/index.html"));
  app.post("/undefined/ExecuteAwardgiver", awardHandler(mln));
  app.get("/api/login", loginHandler(mln));

  final staticHandler = createStaticHandler("static");
  final handler = buildServer(apiHandler: app.call, staticHandler: staticHandler);
  final server = await io.serve(handler, "localhost", 7001);
  print("Serving on http://localhost:${server.port}");
}
