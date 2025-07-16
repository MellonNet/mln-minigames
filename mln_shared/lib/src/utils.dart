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

Future<T?> safelyAsync<T>(Future<T> Function() func) async {
  try {
    return await func();
  // Need to catch all possible errors here
  // ignore: avoid_catches_without_on_clauses
  } catch (error) {
    return null;
  }
}
