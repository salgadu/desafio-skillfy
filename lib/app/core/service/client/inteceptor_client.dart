import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
      print('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      );
      print('Message: ${err.message}');
      if (err.response?.data != null) {
        print('Error Data: ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    if (_shouldRetry(err) && _canRetry(requestOptions)) {
      final retryCount = (requestOptions.extra['retryCount'] as int?) ?? 0;

      if (retryCount < maxRetries) {
        requestOptions.extra['retryCount'] = retryCount + 1;

        if (kDebugMode) {
          print(
            'Retry attempt ${retryCount + 1}/$maxRetries for ${requestOptions.path}',
          );
        }

        await Future.delayed(retryDelay * (retryCount + 1));

        try {
          final dio = Dio();
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {}
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  bool _canRetry(RequestOptions requestOptions) {
    final method = requestOptions.method.toLowerCase();
    return method == 'get' || method == 'head' || method == 'options';
  }
}
