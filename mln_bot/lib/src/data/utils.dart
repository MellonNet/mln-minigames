export "package:mln_shared/mln_shared.dart" show Json;

extension MapUtils<K, V> on Map<K, V> {
  Iterable<(K, V)> get records => entries.map((e) => (e.key, e.value));
}
