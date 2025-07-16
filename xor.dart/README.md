# Symmetric Cipher XOR

[![platform_info](https://img.shields.io/pub/v/xor_dart.svg)](https://pub.dev/packages/xor_dart)

A pure `dart` XOR cipher library, support encryption and decryption with or without a symmetric secret key.

## Usage example

##### 1. with a secret key
```dart
import 'package:xor_dart/xor_dart.dart';

void main() {
  var xor = Xor('_a_random_key_');

  var plain = 'You are so handsome!';
  var encode = xor.encode(plain);
  var decode = xor.decode(encode);

  print('>>> plain: $plain, encode: $encode, decode: $decode');
  print('>>> decryption result is correct: ${plain == decode}'); // true
}
```

##### 2. without a secret key
```dart
import 'dart:convert';
import 'package:xor_dart/xor_dart.dart';

void main() {
  var content = '1234567890';
  var bytes = utf8.encode(content);

  // To bytes
  var en = CipherXor.encrypt(bytes);
  var de = CipherXor.decrypt(en);
  print('content: $bytes, encrypted: $en, decrypted: $de');

  // To strings
  var encrypted = CipherXor.encryptToBase64(content);
  var decrypted = CipherXor.decryptFromBase64(encrypted);
  print('content: $content, encrypted: $encrypted, decrypted: $decrypted');
  print('>>>>>>>> decryption result is correct:: ${content == decrypted}'); // true
}
```


##### 3. XOR encrypt/decrypt a file
```dart
import 'dart:io';
import 'package:xor_dart/xor_dart.dart';

// i.e:
// dart ~/xor.dart/example/main.dart -en nohup.zip nohup.zip.en
// dart ~/xor.dart/example/main.dart -de nohup.zip.en nohup.out.zip
void main(List<String> args) {
  print('args: $args');
  var action = args.first.toLowerCase();

  /// XOR encrypt a file
  if (action.contains('-en')) {
    File(args[2]).writeAsBytesSync(CipherXor.encrypt(File(args[1]).readAsBytesSync()));
  }

  /// XOR decrypt a file
  if (action.contains('-de')) {
    File(args[2]).writeAsBytesSync(CipherXor.decrypt(File(args[1]).readAsBytesSync()));
  }
}
```


## License

[MIT](https://github.com/isaacselement/xor.dart/blob/master/LICENSE)

## Features and bugs

Please feel free to:
request new features and bugs at the [issue tracker][tracker]



[tracker]: https://github.com/isaacselement/xor.dart/issues