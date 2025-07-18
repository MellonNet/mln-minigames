import 'package:http/http.dart';
import 'package:http_status_code/http_status_code.dart';

typedef MlnHeaders = Map<String, String>;

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
