class AppException implements Exception {
  AppException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.statusCode});
}

class OcrException extends AppException {
  OcrException(super.message, {super.statusCode});
}
