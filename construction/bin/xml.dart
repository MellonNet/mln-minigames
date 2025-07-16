import "dart:io";

import "package:mln_shared/mln_shared.dart";

const key = "6276D30C-A7FC-4786-B7D4-5E6D91E2D6BA";
final inputFile = File("static/config_decrypt_modified.xml");
final outputFile = File("static/config.xml");

const before = """
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<config encrypted="true">
<![CDATA[""";

// A newline would break the encryption process
// ignore: leading_newlines_in_multiline_strings
const after = """]]>
</config>
""";

void main() async {
  final source = await inputFile.readAsString();
  final encrypted = encrypt(key: key, source: source);
  final newXml = before + encrypted + after;
  await outputFile.writeAsString(newXml);
}
