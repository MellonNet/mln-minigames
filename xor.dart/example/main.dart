import 'dart:io';
import 'package:xor_dart/xor_dart.dart';

void main2() {
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
}

// i.e:
// dart ~/xor.dart/example/main.dart -en nohup.zip nohup.zip.en
// dart ~/xor.dart/example/main.dart -de nohup.zip.en nohup.out.zip
void main(List<String> args) {
  print('args: $args');
  var action = args.first.toLowerCase();
  var src = args[1];
  var dst = args[2];

  /// XOR encrypt a file
  if (action.contains('-en')) {
    File(dst).writeAsBytesSync(CipherXor.encrypt(File(src).readAsBytesSync()));
  }

  /// XOR decrypt a file
  if (action.contains('-de')) {
    File(dst).writeAsBytesSync(CipherXor.decrypt(File(src).readAsBytesSync()));
  }
}
