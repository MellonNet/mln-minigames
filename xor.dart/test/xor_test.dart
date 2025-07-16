import 'dart:convert';
import 'package:test/test.dart';
import 'package:xor_dart/xor_dart.dart';

void main() {
  bool isListEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  group('XOR', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('XOR encryption & decryption', () async {
      /// with secret key
      var xor = Xor('_a_random_key_');
      var plain = 'You are so handsome!';
      var encode = xor.encode(plain);
      var decode = xor.decode(encode);

      print('>>> plain: $plain, encode: $encode, decode: $decode');
      print('>>> decryption result is correct: ${plain == decode}');

      /// without secret key
      var content = '1234567890';
      var encrypted = CipherXor.encryptToBase64(content);
      var decrypted = CipherXor.decryptFromBase64(encrypted);
      print('content: $content, encrypted: $encrypted, decrypted: $decrypted');
      print('>>> decryption result is correct:: ${content == decrypted}');

      /// xor bytes without secret key
      var bytes = utf8.encode('So calm down ~~~');
      var en = CipherXor.encrypt(bytes);
      var de = CipherXor.decrypt(en);
      print('content: $bytes, encrypted: $en, decrypted: $de');
      expect(isListEqual(bytes, de), isTrue);

      /// xor bytes with secret key
      var keyBytes = ascii.encode('key666');
      var enWithKey = CipherXor.xor(bytes, keyBytes);
      var deWithKey = CipherXor.xor(enWithKey, keyBytes);
      print('content: $bytes, enWithKey: $enWithKey, deWithKey: $deWithKey');
      expect(isListEqual(bytes, deWithKey), isTrue);
    });
  });
}
