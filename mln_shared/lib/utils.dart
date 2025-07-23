import "package:http/http.dart";
import "package:http_status_code/http_status_code.dart";
import "package:xor_dart/xor_dart.dart";

typedef Json = Map<String, dynamic>;

String decrypt({
  required String key,
  required String source,
}) => CipherXor.xorFromBase64(source, key);

String encrypt({
  required String key,
  required String source,
}) => CipherXor.xorToBase64(source, key);

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

class ApiException implements Exception {
  final String message;
  ApiException(Response response) :
    message = response.body.nullIfEmpty ?? getStatusMessage(response.statusCode);

  @override
  String toString() => message;
}

extension ResponseUtils on Response {
  Response get ifOk => statusCode >= 200 && statusCode < 300
    ? this : throw ApiException(this);
}

extension MapUtils<K, V> on Map<K, V> {
  Iterable<(K, V)> get records => entries.map((e) => (e.key, e.value));
}

extension FutureUtils<T> on Future<T> {
  Future<T?> ignoreApiErrors() async {
    try {
      return await this;
    } on ApiException {
      return null;
    }
  }

  Future<T?> ignoreAllErrors() async {
    try {
      return await timeout(const Duration(seconds: 3));
    // Catch all errors
    // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }
}
