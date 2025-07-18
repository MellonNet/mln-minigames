export "package:mln_shared/mln_shared.dart" show Json;

extension type WebhookID(int id) { }

extension MapUtils<K, V> on Map<K, V> {
  Iterable<(K, V)> get records => entries.map((e) => (e.key, e.value));
}

Future<T?> tryAsync<T>(Future<T> Function() func) async {
  try {
    return await func().timeout(const Duration(seconds: 1));
  // Catch all errors
  // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return null;
  }
}
