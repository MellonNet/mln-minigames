import 'dart:convert';

/// XOR class holding a secret key
class Xor {
  late List<int> keys;

  Xor(String secretKey) {
    keys = ascii.encode(secretKey);
  }

  /// basic byte-level encryption & decryption
  List<int> encrypt(List<int> bytes) => CipherXor.xor(bytes, keys);

  List<int> decrypt(List<int> bytes) => CipherXor.xor(bytes, keys);

  /// base64 string-level encryption & decryption
  String encode(String content) => base64.encode(encrypt(utf8.encode(content)));

  String decode(String content) => utf8.decode(decrypt(base64.decode(content)));
}

/// Basic XOR Cipher for encryption & decryption
class CipherXor {
  /// base64 encryption and decryption
  static String encryptToBase64(String content) {
    return base64.encode(encrypt(utf8.encode(content)));
  }

  static String decryptFromBase64(String content) {
    return utf8.decode(decrypt(base64.decode(content)));
  }

  /// bytes encryption and decryption
  static List<int> encryptToBytes(String content) {
    return encrypt(utf8.encode(content));
  }

  static List<int> decryptToBytes(String content) {
    return decrypt(utf8.encode(content));
  }

  /// basic bytes encryption and decryption, without a key just xor with its next byte :)
  static List<int> encrypt(List<int> bytes) {
    var encrypted = <int>[...bytes];
    var length = encrypted.length;
    for (var i = 0; i < length; i++) {
      var j = (i + 1 >= length) ? 0 : i + 1;
      encrypted[i] = encrypted[i] ^ encrypted[j];
    }
    return encrypted;
  }

  static List<int> decrypt(List<int> bytes) {
    var decrypted = <int>[...bytes];
    var length = decrypted.length;
    for (var i = length - 1; i >= 0; i--) {
      var j = (i + 1 >= length) ? 0 : i + 1;
      decrypted[i] = decrypted[i] ^ decrypted[j];
    }
    return decrypted;
  }

  /// exchanged encryption & decryption using the same secret key
  static List<int> xor(List<int> bytes, List<int> keys) => [
        for (final (index, byte) in bytes.indexed)
          byte ^ keys[index % keys.length],
      ];

  /// convenient XOR (with secret key) method for encrypting plain-text to base64 or decrypting encrypted-base64 to plain-text
  static String xorToBase64(String content, String key) {
    return base64.encode(xor(utf8.encode(content), utf8.encode(key)));
  }

  static String xorFromBase64(String content, String key) {
    return utf8.decode(xor(base64.decode(content), utf8.encode(key)));
  }
}
