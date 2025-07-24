import 'package:desafio_skillfy/app/core/service/client/i_http_client.dart';
import 'package:desafio_skillfy/app/core/service/client/inteceptor_client.dart';
import 'package:desafio_skillfy/app/core/constants/env.dart';
import 'package:dio/dio.dart' as http;

class DioFactory {
  static http.Dio dio() {
    final baseOptions = http.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: configTimeout),
      receiveTimeout: Duration(seconds: configReceiveTimeout),
      sendTimeout: Duration(seconds: configTimeout),
      receiveDataWhenStatusError: true,
      followRedirects: true,
      // headers: {
      //   'Content-Type': 'application/json',
      //   'Accept': 'application/json',
      // },
    );

    var dio = http.Dio(baseOptions);
    dio.interceptors.addAll([RetryInterceptor(), LoggingInterceptor()]);
    return dio;
  }
}

class DioHttpClient implements IHttpClient {
  final http.Dio _dio;
  final String baseUrl;

  DioHttpClient(this._dio, {required this.baseUrl});

  @override
  Future<HttpResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: http.Options(headers: headers),
      );
      return _handleResponse(response);
    } on http.DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return HttpResponse.error('Erro inesperado: ${e.toString()}');
    }
  }

  @override
  Future<HttpResponse<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: http.Options(headers: headers),
      );
      return _handleResponse(response);
    } on http.DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return HttpResponse.error('Erro inesperado: ${e.toString()}');
    }
  }

  @override
  Future<HttpResponse<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: http.Options(headers: headers),
      );
      return _handleResponse(response);
    } on http.DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return HttpResponse.error('Erro inesperado: ${e.toString()}');
    }
  }

  @override
  Future<HttpResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: http.Options(headers: headers),
      );
      return _handleResponse(response);
    } on http.DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return HttpResponse.error('Erro inesperado: ${e.toString()}');
    }
  }

  HttpResponse<dynamic> _handleResponse(http.Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return HttpResponse.success(
        response.data,
        statusCode: response.statusCode!,
      );
    } else {
      return HttpResponse.error(
        'Erro HTTP: ${response.statusCode}',
        statusCode: response.statusCode ?? 500,
        data: response.data,
      );
    }
  }

  HttpResponse<dynamic> _handleError(http.DioException error) {
    String message;
    int statusCode = error.response?.statusCode ?? 500;

    switch (error.type) {
      case http.DioExceptionType.connectionTimeout:
        message = 'Tempo limite de conexão excedido';
        break;
      case http.DioExceptionType.sendTimeout:
        message = 'Tempo limite de envio excedido';
        break;
      case http.DioExceptionType.receiveTimeout:
        message = 'Tempo limite de recebimento excedido';
        break;
      case http.DioExceptionType.badResponse:
        message = _getErrorMessageFromResponse(error.response);
        break;
      case http.DioExceptionType.cancel:
        message = 'Requisição cancelada';
        break;
      case http.DioExceptionType.connectionError:
        message = 'Erro de conexão. Verifique sua internet';
        break;
      case http.DioExceptionType.badCertificate:
        message = 'Erro de certificado SSL';
        break;
      case http.DioExceptionType.unknown:
        message = 'Erro desconhecido: ${error.message}';
        break;
    }

    return HttpResponse.error(
      message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  String _getErrorMessageFromResponse(http.Response? response) {
    if (response?.data != null) {
      try {
        final data = response!.data;
        if (data is Map<String, dynamic>) {
          // Tenta extrair mensagem de erro do JSON
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
          if (data.containsKey('error')) {
            return data['error'].toString();
          }
          if (data.containsKey('errors')) {
            final errors = data['errors'];
            if (errors is List && errors.isNotEmpty) {
              return errors.first.toString();
            }
          }
        }
      } catch (e) {
        // Se não conseguir parsear, retorna erro genérico
      }
    }

    // Fallback para código de status HTTP
    switch (response?.statusCode) {
      case 400:
        return 'Requisição inválida';
      case 401:
        return 'Não autorizado';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 422:
        return 'Dados inválidos';
      case 429:
        return 'Muitas requisições. Tente novamente mais tarde';
      case 500:
        return 'Erro interno do servidor';
      case 502:
        return 'Servidor indisponível';
      case 503:
        return 'Serviço temporariamente indisponível';
      default:
        return 'Erro HTTP: ${response?.statusCode ?? 'Desconhecido'}';
    }
  }
}
