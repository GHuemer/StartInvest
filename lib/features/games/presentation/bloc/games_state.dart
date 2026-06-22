part of 'games_bloc.dart';

abstract class GamesState extends Equatable {
  const GamesState();

  @override
  List<Object?> get props => [];
}

class GamesInitial extends GamesState {
  const GamesInitial();
}

class GameLoading extends GamesState {
  const GameLoading();
}

class GameStarted extends GamesState {
  final GameSession session;

  const GameStarted(this.session);

  @override
  List<Object?> get props => [session];
}

class QuestionAnswered extends GamesState {
  final GameSession session;
  final bool isCorrect;
  final int pointsEarned;

  const QuestionAnswered({
    required this.session,
    required this.isCorrect,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [session, isCorrect, pointsEarned];
}

class GameFinished extends GamesState {
  final GameResult result;

  const GameFinished(this.result);

  @override
  List<Object?> get props => [result];
}

class GamesError extends GamesState {
  final String message;

  const GamesError(this.message);

  @override
  List<Object?> get props => [message];
}
