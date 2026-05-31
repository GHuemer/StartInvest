import 'package:equatable/equatable.dart';
import '../../domain/entities/challenge.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final Challenge? dailyChallenge;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.dailyChallenge,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    Challenge? dailyChallenge,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      dailyChallenge: dailyChallenge ?? this.dailyChallenge,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dailyChallenge, errorMessage];
}
