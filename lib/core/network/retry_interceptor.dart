import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = AppConstants.maxRetries});

  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRetry = _shouldRetry(err);
    final attempt = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    if (shouldRetry && attempt < maxRetries) {
      err.requestOptions.extra['retryCount'] = attempt + 1;
      await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      try {
        final response = await Dio().fetch<dynamic>(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
