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
    final response = await _client.get(uri, headers: authHeaders).ignoreAllErrors();
    return response?.ifOk;
  }

  Future<Response?> post(String path, [Json? body]) async {
    final uri = buildUri(path);
    final bodyString = jsonEncode(body);
    final response = await _client.post(uri, headers: authHeaders, body: bodyString).ignoreAllErrors();
    return response?.ifOk;
  }

  Future<bool> delete(String path) async {
    // DELETE is a special case. Most errors are valid errors, like 403.
    // But 404 is a non-error, since the end state is that the resource is gone.
    final uri = buildUri(path);
    final response = await _client.delete(uri, headers: authHeaders).ignoreAllErrors();
    return response != null && (response.isOk || response.statusCode == 404);
  }

  Future<Json?> getJson(String path) async {
    final response = await get(path);
    if (response == null) return null;
    return Json.from(jsonDecode(response.body));
  }

  Future<List<Json>?> getJsonList(String path) async {
    final response = await get(path);
    if (response == null) return null;
    final data = jsonDecode(response.body) as List;
    return data.cast<Json>();
  }

  Future<Json?> postJson(String path, [Json? body]) async {
    final response = await post(path, body);
    if (response == null) return null;
    return Json.from(jsonDecode(response.body));
  }
}
