import "dart:io";

import "package:collection/collection.dart";
import "package:shelf/shelf.dart";

import "oauth.dart";

extension RequestUtils on Request {
  List<Cookie> get cookies {
    final header = headers[HttpHeaders.cookieHeader];
    if (header == null) return [];
    final result = <Cookie>[];
    for (final rawCookie in header.split("; ")) {
      final [name, value] = rawCookie.split("=");
      final cookie = Cookie(name, value);
      result.add(cookie);
    }
    return result;
  }

  SessionID? get sessionID {
    final result = cookies.firstWhereOrNull((cookie) => cookie.name == "sessionid")?.value;
    if (result == null) return null;
    return SessionID(result);
  }
}

extension ResponseUtils on Response {
  Response setCookie(Cookie cookie) => change(
    headers: {HttpHeaders.setCookieHeader: cookie.toString()},
  );
}

Handler sessionMiddleware(Handler innerHandler) => (request) async {
  final response = await innerHandler(request);
  if (request.sessionID == null) {
    final cookie = Cookie("sessionid", OAuth.getSessionID().value);
    return response.setCookie(cookie);
  }
  return response;
};

Handler doNotCache(Handler innerHandler) => (request) async {
  final response = await innerHandler(request);
  return response.change(
    headers: {
      HttpHeaders.cacheControlHeader: "no-cache",
    },
  );
};

Handler buildServer({
  required Handler apiHandler,
  required Handler staticHandler,
}) {
  final cascade = Cascade()
    .add(staticHandler)
    .add(apiHandler);

  return const Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware(sessionMiddleware)
    .addMiddleware(doNotCache)
    .addHandler(cascade.handler);
}
