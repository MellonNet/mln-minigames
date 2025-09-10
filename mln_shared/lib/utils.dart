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

extension StringUtils on String {
  String? get nullIfEmpty => isEmpty ? null : this;

  bool fuzzyMatch(String query) {
    final parts = toLowerCase().split(" ");
    return query.toLowerCase().split(" ")
      .every((queryPart) => parts.any((part) => part.contains(queryPart)));
  }

  bool caseInsensitive(String other) => toLowerCase() == other.toLowerCase();
  bool containsInsensitive(String other) => toLowerCase().contains(other.toLowerCase());

  (String, String)? splitFirst(String pattern) {
    final index = indexOf(pattern);
    if (index == -1) return null;
    return (substring(0, index), substring(index + 1));
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(Response response) :
    message = response.body.nullIfEmpty ?? getStatusMessage(response.statusCode);

  ApiException.from(this.message);

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
