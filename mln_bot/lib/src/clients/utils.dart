import "package:mln_shared/mln_shared.dart";

extension F1Utils<T extends Object> on Future<T?> {
  static String _toString(Object x) => x.toString();

  Future<String> handle([String Function(T) describe = _toString]) async {
    try {
      final result = await this;
      if (result == null) return "An error occurred";
      return describe(result);
    } on ApiException catch (error) {
      return error.toString();
    }
  }
}
