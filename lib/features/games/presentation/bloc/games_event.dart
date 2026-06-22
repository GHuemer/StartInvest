part of 'games_bloc.dart';

abstract class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object?> get props => [];
}

class StartMarketPredictorEvent extends GamesEvent {
  final String difficulty;

  const StartMarketPredictorEvent(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

class AnswerQuestionEvent extends GamesEvent {
  final bool answer; // true = sobe, false = desce

  const AnswerQuestionEvent(this.answer);

  @override
  List<Object?> get props => [answer];
}

class NextQuestionEvent extends GamesEvent {
  const NextQuestionEvent();
}

class FinishGameEvent extends GamesEvent {
  const FinishGameEvent();
}

class ResetGameEvent extends GamesEvent {
  const ResetGameEvent();
}
