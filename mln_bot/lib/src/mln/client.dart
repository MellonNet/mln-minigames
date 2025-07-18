import "dart:convert";

import "package:http/http.dart";
import "package:mln_bot/data.dart";

import "utils.dart";

class JsonClient {
  final _client = Client();

  final String host;
  final MlnHeaders authHeaders;
  JsonClient({
    required this.host,
    required this.authHeaders,
  });

  void dispose() => _client.close();

  Future<T?> _tryAsync<T>(Future<T> Function() func) async {
    try {
      return await func();
    } catch (_) {
      return null;
    }
  }

  Uri buildUri(String path) => Uri.parse("$host/$path");

  Future<Response?> get(String path) async {
    final uri = buildUri(path);
    final response = await _tryAsync(() => _client.get(uri, headers: authHeaders));
    return response?.ifOk;
  }

  Future<Response?> post(String path, Json body) async {
    final uri = buildUri(path);
    final bodyString = jsonEncode(body);
    final response = await _tryAsync(() => _client.post(uri, headers: authHeaders, body: bodyString));
    return response?.ifOk;
  }

  Future<Response?> delete(String path) async {
    final uri = buildUri(path);
    final response = await _tryAsync(() => _client.delete(uri, headers: authHeaders));
    return response?.ifOk;
  }

  Future<Json?> getJson(String path) async {
    final response = await get(path);
    if (response == null) return null;
    return Json.from(jsonDecode(response.body));
  }

  Future<Json?> postJson(String path, Json body) async {
    final response = await post(path, body);
    if (response == null) return null;
    return Json.from(jsonDecode(response.body));
  }
}
