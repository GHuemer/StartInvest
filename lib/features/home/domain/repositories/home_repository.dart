import '../entities/challenge.dart';

abstract class HomeRepository {
  /// Obtém o desafio diário do usuário
  Future<Challenge> getDailyChallenge();

  /// Futuros métodos para implementar:
}
