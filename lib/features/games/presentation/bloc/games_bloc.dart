import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/games_repository.dart';

part 'games_event.dart';
part 'games_state.dart';

@injectable
class GamesBloc extends Bloc<GamesEvent, GamesState> {
  final GamesRepository _repository;

  GamesBloc(this._repository) : super(const GamesInitial()) {
    on<StartMarketPredictorEvent>(_onStartMarketPredictor);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<NextQuestionEvent>(_onNextQuestion);
    on<FinishGameEvent>(_onFinishGame);
    on<ResetGameEvent>(_onResetGame);
  }

  Future<void> _onStartMarketPredictor(
    StartMarketPredictorEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(const GameLoading());

    final result = await _repository.createGameSession(event.difficulty);

    result.fold(
      (failure) => emit(const GamesError('Erro ao iniciar jogo')),
      (session) => emit(GameStarted(session)),
    );
  }

  Future<void> _onAnswerQuestion(
    AnswerQuestionEvent event,
    Emitter<GamesState> emit,
  ) async {
    final currentState = state;

    if (currentState is! GameStarted) return;

    final session = currentState.session;
    final currentQuestion = session.questions[session.currentQuestionIndex];
    final isCorrect = event.answer == currentQuestion.correctAnswer;

    // Atualiza a lista de respostas
    final newAnswers = List<bool>.from(session.answers)..add(event.answer);

    // Calcula pontos apenas se acertou
    int pointsEarned = 0;
    if (isCorrect) {
      pointsEarned =
          session.calculatePointsForQuestion(session.currentQuestionIndex);
    }

    final totalPoints = session.totalPoints + pointsEarned;

    final updatedSession = session.copyWith(
      answers: newAnswers,
      totalPoints: totalPoints,
    );

    emit(QuestionAnswered(
      session: updatedSession,
      isCorrect: isCorrect,
      pointsEarned: pointsEarned,
    ));
  }

  Future<void> _onNextQuestion(
    NextQuestionEvent event,
    Emitter<GamesState> emit,
  ) async {
    final currentState = state;

    if (currentState is! QuestionAnswered) return;

    final session = currentState.session;
    final nextIndex = session.currentQuestionIndex + 1;

    if (nextIndex < session.questions.length) {
      final updatedSession = session.copyWith(
        currentQuestionIndex: nextIndex,
      );
      emit(GameStarted(updatedSession));
    } else {
      // Fim do jogo
      add(const FinishGameEvent());
    }
  }

  Future<void> _onFinishGame(
    FinishGameEvent event,
    Emitter<GamesState> emit,
  ) async {
    final currentState = state;

    GameSession? session;
    if (currentState is GameStarted) {
      session = currentState.session;
    } else if (currentState is QuestionAnswered) {
      session = currentState.session;
    }

    if (session == null) return;

    final result = await _repository.finishGameSession(session);

    if (result.isLeft()) {
      emit(const GamesError('Erro ao finalizar jogo'));
      return;
    }

    final gameResult = result.getOrElse(() => throw Exception());

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _repository.saveGameResult(gameResult, userId);
    }

    emit(GameFinished(gameResult));
  }

  Future<void> _onResetGame(
    ResetGameEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(const GamesInitial());
  }
}
