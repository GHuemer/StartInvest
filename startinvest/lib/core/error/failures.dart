import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Falha na autenticação']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar dados locais']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso não encontrado']);
}
