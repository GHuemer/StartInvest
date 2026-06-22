import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final String name;
  final String username;
  final String memberSince;
  final int friendsCount;
  final int streak;
  final int xp;
  final String league;
  final int podiums;

  const ProfileLoaded({
    required this.name,
    required this.username,
    required this.memberSince,
    required this.friendsCount,
    required this.streak,
    required this.xp,
    required this.league,
    required this.podiums,
  });

  ProfileLoaded copyWith({
    String? name,
    String? username,
    String? memberSince,
    int? friendsCount,
    int? streak,
    int? xp,
    String? league,
    int? podiums,
  }) {
    return ProfileLoaded(
      name: name ?? this.name,
      username: username ?? this.username,
      memberSince: memberSince ?? this.memberSince,
      friendsCount: friendsCount ?? this.friendsCount,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      league: league ?? this.league,
      podiums: podiums ?? this.podiums,
    );
  }

  @override
  List<Object?> get props => [
    name,
    username,
    memberSince,
    friendsCount,
    streak,
    xp,
    league,
    podiums,
  ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
