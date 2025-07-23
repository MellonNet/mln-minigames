import "dart:convert";

import "package:http/http.dart";

import "package:mln_shared/utils.dart";

typedef MlnHeaders = Map<String, String>;

class JsonClient {
  final _client = Client();

  final String urlBase;
  final MlnHeaders? authHeaders;
  JsonClient({
    required this.urlBase,
    this.authHeaders,
  });

  void dispose() => _client.close();

  Uri buildUri(String path) => Uri.parse("$urlBase$path");

  Future<Response?> get(String path) async {
    final uri = buildUri(path);
    final response = await tryAsync(() => _client.get(uri, headers: authHeaders));
    return response?.ifOk;
  }

  Future<Response?> post(String path, [Json? body]) async {
    final uri = buildUri(path);
    final bodyString = jsonEncode(body);
    final response = await tryAsync(() => _client.post(uri, headers: authHeaders, body: bodyString));
    return response?.ifOk;
  }

  Future<Response?> delete(String path) async {
    final uri = buildUri(path);
    final response = await tryAsync(() => _client.delete(uri, headers: authHeaders));
    return response?.ifOk;
  }

  Future<Json?> getJson(String path) async {
    final response = await get(path);
    if (response == null) return null;
    return Json.from(jsonDecode(response.body));
  }

  Future<Json?> postJson(String path, [Json? body]) async {
    final response = await post(path, body);
    if (response == null) return null;
    return Json.from(jsonDecode(response.body));
  }
}
