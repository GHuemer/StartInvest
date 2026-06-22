import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/market_question.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/market_questions_datasource.dart';
import '../models/market_question_model.dart';

@LazySingleton(as: GamesRepository)
class GamesRepositoryImpl implements GamesRepository {
  final MarketQuestionsDatasource _datasource;
  final FirebaseFirestore _firestore;

  GamesRepositoryImpl({
    required MarketQuestionsDatasource datasource,
    FirebaseFirestore? firestore,
  })  : _datasource = datasource,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<MarketQuestion>>> getQuestionsByDifficulty(
    String difficulty,
  ) async {
    try {
      final questions = await _datasource.getQuestionsByDifficulty(difficulty);
      return Right(questions);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar questões'));
    }
  }

  @override
  Future<Either<Failure, GameSession>> createGameSession(
    String difficulty,
  ) async {
    try {
      final questionsResult = await getQuestionsByDifficulty(difficulty);
      return questionsResult.fold(
        (failure) => Left(failure),
        (questions) => Right(
          GameSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            difficulty: difficulty,
            questions: questions,
            startedAt: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao criar sessão de jogo'));
    }
  }

  @override
  Future<Either<Failure, GameSession>> updateGameSession(
    GameSession session,
  ) async {
    try {
      return Right(session);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar sessão'));
    }
  }

  @override
  Future<Either<Failure, GameResult>> finishGameSession(
    GameSession session,
  ) async {
    try {
      int correctAnswers = 0;
      for (int i = 0; i < session.answers.length; i++) {
        if (session.answers[i] == session.questions[i].correctAnswer) {
          correctAnswers++;
        }
      }

      final accuracy =
          (correctAnswers / session.questions.length * 100).toStringAsFixed(2);

      int bestStreak = 0;
      int currentStreak = 0;
      for (int i = 0; i < session.answers.length; i++) {
        if (session.answers[i] == session.questions[i].correctAnswer) {
          currentStreak++;
          bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
        } else {
          currentStreak = 0;
        }
      }

      final result = GameResult(
        sessionId: session.id,
        difficulty: session.difficulty,
        totalPoints: session.totalPoints,
        correctAnswers: correctAnswers,
        totalQuestions: session.questions.length,
        accuracy: double.parse(accuracy),
        completedAt: DateTime.now(),
        bestStreak: bestStreak,
      );

      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Erro ao finalizar jogo'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGameResult(
    GameResult result,
    String userId,
  ) async {
    try {
      await Future.wait([
        _firestore
            .collection('users')
            .doc(userId)
            .collection('game_results')
            .add(result.toMap()),
        _firestore
            .collection('users')
            .doc(userId)
            .update({'xp': FieldValue.increment(result.totalPoints)}),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao salvar resultado'));
    }
  }

  @override
  Future<Either<Failure, List<GameResult>>> getUserGameResults(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('game_results')
          .orderBy('completedAt', descending: true)
          .get();

      final results = snapshot.docs
          .map(
            (doc) => GameResult(
              sessionId: doc['sessionId'],
              difficulty: doc['difficulty'],
              totalPoints: doc['totalPoints'],
              correctAnswers: doc['correctAnswers'],
              totalQuestions: doc['totalQuestions'],
              accuracy: doc['accuracy'],
              completedAt: DateTime.parse(doc['completedAt']),
              bestStreak: doc['bestStreak'],
            ),
          )
          .toList();

      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar resultados'));
    }
  }
}
