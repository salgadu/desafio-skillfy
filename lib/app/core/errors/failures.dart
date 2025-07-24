class BaseException implements Exception {
  final String message;

  BaseException(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends BaseException {
  NetworkFailure([super.message = 'Sem conexão com a internet']);
}

class ServerFailure extends BaseException {
  ServerFailure([super.message = 'Erro do servidor']);
}

class UnauthorizedFailure extends BaseException {
  UnauthorizedFailure([super.message = 'Acesso negado']);
}

class NotFoundFailure extends BaseException {
  NotFoundFailure([super.message = 'Não encontrado']);
}

class DataSourceFailure extends BaseException {
  DataSourceFailure([super.message = 'Erro ao buscar dados']);
}

class ValidationFailure extends BaseException {
  ValidationFailure([super.message = 'Dados inválidos']);
}

class EmptyDataFailure extends BaseException {
  EmptyDataFailure([super.message = 'Nenhum dado encontrado']);
}

class CacheFailure extends BaseException {
  CacheFailure([super.message = 'Erro no cache']);
}

class FileFailure extends BaseException {
  FileFailure([super.message = 'Erro no arquivo']);
}

class UnknownFailure extends BaseException {
  UnknownFailure([super.message = 'Erro desconhecido']);
}
