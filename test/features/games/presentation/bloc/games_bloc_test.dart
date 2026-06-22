import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/games/domain/entities/game_session.dart';
import 'package:startinvest/features/games/domain/entities/market_question.dart';
import 'package:startinvest/features/games/domain/repositories/games_repository.dart';
import 'package:startinvest/features/games/presentation/bloc/games_bloc.dart';

class MockGamesRepository extends Mock implements GamesRepository {}

MarketQuestion _makeQuestion({bool correctAnswer = true}) => MarketQuestion(
      id: 'q1',
      story: 'A empresa X reportou lucro recorde...',
      company: 'Empresa X',
      correctAnswer: correctAnswer,
      difficulty: 'easy',
    );

GameSession _makeSession({List<MarketQuestion>? questions}) => GameSession(
      id: 'session-1',
      difficulty: 'easy',
      questions: questions ?? [_makeQuestion()],
      startedAt: DateTime(2024),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(GameSession(
      id: 'fallback',
      difficulty: 'easy',
      questions: [],
      startedAt: DateTime(2024),
    ));
  });

  late GamesBloc bloc;
  late MockGamesRepository mockRepository;

  setUp(() {
    mockRepository = MockGamesRepository();
    bloc = GamesBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  test('estado inicial deve ser GamesInitial', () {
    expect(bloc.state, const GamesInitial());
  });

  group('StartMarketPredictorEvent', () {
    blocTest<GamesBloc, GamesState>(
      'deve emitir [GameLoading, GameStarted] em caso de sucesso',
      build: () {
        when(() => mockRepository.createGameSession('easy'))
            .thenAnswer((_) async => Right(_makeSession()));
        return bloc;
      },
      act: (b) => b.add(const StartMarketPredictorEvent('easy')),
      expect: () => [
        const GameLoading(),
        isA<GameStarted>(),
      ],
    );

    blocTest<GamesBloc, GamesState>(
      'deve emitir [GameLoading, GamesError] em caso de falha',
      build: () {
        when(() => mockRepository.createGameSession(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Sem conexão')));
        return bloc;
      },
      act: (b) => b.add(const StartMarketPredictorEvent('easy')),
      expect: () => [
        const GameLoading(),
        const GamesError('Erro ao iniciar jogo'),
      ],
    );
  });

  group('AnswerQuestionEvent', () {
    blocTest<GamesBloc, GamesState>(
      'deve emitir QuestionAnswered com isCorrect=true para resposta correta',
      build: () {
        when(() => mockRepository.createGameSession('easy'))
            .thenAnswer((_) async => Right(_makeSession()));
        return bloc;
      },
      seed: () => GameStarted(_makeSession(questions: [_makeQuestion(correctAnswer: true)])),
      act: (b) => b.add(const AnswerQuestionEvent(true)),
      expect: () => [
        isA<QuestionAnswered>().having((s) => s.isCorrect, 'isCorrect', true),
      ],
    );

    blocTest<GamesBloc, GamesState>(
      'deve emitir QuestionAnswered com isCorrect=false para resposta errada',
      build: () => bloc,
      seed: () => GameStarted(_makeSession(questions: [_makeQuestion(correctAnswer: true)])),
      act: (b) => b.add(const AnswerQuestionEvent(false)),
      expect: () => [
        isA<QuestionAnswered>()
            .having((s) => s.isCorrect, 'isCorrect', false)
            .having((s) => s.pointsEarned, 'pointsEarned', 0),
      ],
    );

    blocTest<GamesBloc, GamesState>(
      'deve conceder pontos pelo índice da questão em caso de acerto',
      build: () => bloc,
      seed: () => GameStarted(_makeSession(questions: [_makeQuestion(correctAnswer: false)])),
      act: (b) => b.add(const AnswerQuestionEvent(false)),
      expect: () => [
        isA<QuestionAnswered>()
            .having((s) => s.isCorrect, 'isCorrect', true)
            .having((s) => s.pointsEarned, 'pointsEarned', greaterThan(0)),
      ],
    );

    blocTest<GamesBloc, GamesState>(
      'deve ignorar o evento quando estado não for GameStarted',
      build: () => bloc,
      seed: () => const GamesInitial(),
      act: (b) => b.add(const AnswerQuestionEvent(true)),
      expect: () => [],
    );
  });

  group('NextQuestionEvent', () {
    blocTest<GamesBloc, GamesState>(
      'deve avançar para a próxima questão emitindo GameStarted',
      build: () => bloc,
      seed: () => QuestionAnswered(
        session: _makeSession(
          questions: [_makeQuestion(), _makeQuestion()],
        ),
        isCorrect: true,
        pointsEarned: 5,
      ),
      act: (b) => b.add(const NextQuestionEvent()),
      expect: () => [
        isA<GameStarted>().having(
          (s) => s.session.currentQuestionIndex,
          'currentQuestionIndex',
          1,
        ),
      ],
    );

    blocTest<GamesBloc, GamesState>(
      'deve ignorar o evento quando estado não for QuestionAnswered',
      build: () => bloc,
      seed: () => const GamesInitial(),
      act: (b) => b.add(const NextQuestionEvent()),
      expect: () => [],
    );
  });

  group('FinishGameEvent', () {
    blocTest<GamesBloc, GamesState>(
      'deve emitir GamesError quando finishGameSession falhar',
      build: () {
        when(() => mockRepository.finishGameSession(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Erro ao salvar')));
        return bloc;
      },
      seed: () => GameStarted(_makeSession()),
      act: (b) => b.add(const FinishGameEvent()),
      expect: () => [const GamesError('Erro ao finalizar jogo')],
    );

    blocTest<GamesBloc, GamesState>(
      'deve ignorar o evento quando não houver sessão ativa',
      build: () => bloc,
      seed: () => const GamesInitial(),
      act: (b) => b.add(const FinishGameEvent()),
      expect: () => [],
    );
  });

  group('ResetGameEvent', () {
    blocTest<GamesBloc, GamesState>(
      'deve emitir GamesInitial',
      build: () => bloc,
      seed: () => GameStarted(_makeSession()),
      act: (b) => b.add(const ResetGameEvent()),
      expect: () => [const GamesInitial()],
    );
  });
}
