abstract class IHttpClient {
  Future<HttpResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<HttpResponse<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<HttpResponse<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<HttpResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}

class HttpResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final bool isSuccess;

  HttpResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.isSuccess,
  });

  factory HttpResponse.success(T data, {int statusCode = 200}) {
    return HttpResponse<T>(data: data, statusCode: statusCode, isSuccess: true);
  }

  factory HttpResponse.error(String message, {int statusCode = 500, T? data}) {
    return HttpResponse<T>(
      data: data,
      statusCode: statusCode,
      message: message,
      isSuccess: false,
    );
  }
}
