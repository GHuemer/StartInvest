import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_result.dart';
import '../entities/game_session.dart';
import '../entities/market_question.dart';

abstract class GamesRepository {
  Future<Either<Failure, List<MarketQuestion>>> getQuestionsByDifficulty(
    String difficulty,
  );

  Future<Either<Failure, GameSession>> createGameSession(
    String difficulty,
  );

  Future<Either<Failure, GameSession>> updateGameSession(
    GameSession session,
  );

  Future<Either<Failure, GameResult>> finishGameSession(
    GameSession session,
  );

  Future<Either<Failure, void>> saveGameResult(
    GameResult result,
    String userId,
  );

  Future<Either<Failure, List<GameResult>>> getUserGameResults(
    String userId,
  );
}
