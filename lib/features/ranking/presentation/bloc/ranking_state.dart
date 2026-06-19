import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/user_profile.dart';

abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

class RankingInitial extends RankingState {
  const RankingInitial();
}

class RankingLoading extends RankingState {
  const RankingLoading();
}

class RankingLoaded extends RankingState {
  final List<UserProfile> globalRanking;
  final List<UserProfile> friendsRanking;

  const RankingLoaded({
    required this.globalRanking,
    required this.friendsRanking,
  });

  @override
  List<Object?> get props => [globalRanking, friendsRanking];
}

class RankingError extends RankingState {
  final String message;
  const RankingError(this.message);

  @override
  List<Object?> get props => [message];
}
