import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  ProfileCubit(this._authRepository, this._profileRepository) : super(const ProfileInitial());

  Future<void> logout() async {
    await _authRepository.signOut();
  }

  Future<void> loadProfile({bool force = false}) async {
    if (state is ProfileLoaded && !force) return;

    emit(const ProfileLoading());

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      emit(const ProfileError('Usuário não autenticado'));
      return;
    }

    final result = await _profileRepository.getUserProfile(currentUser.id);
    
    result.fold(
      (failure) => emit(ProfileError(failure.toString())),
      (profile) => emit(ProfileLoaded(
        name: profile.name,
        username: profile.username,
        memberSince: profile.memberSince,
        friendsCount: profile.friendIds.length,
        streak: profile.loginStreak,
        xp: profile.xp,
        league: profile.league,
        podiums: 0,
      )),
    );
  }

  Future<void> updateName(String newName) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final previousName = currentState.name;
      emit(currentState.copyWith(name: newName));

      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final profileResult = await _profileRepository.getUserProfile(currentUser.id);
        profileResult.fold(
          (failure) => emit(currentState),
          (profile) async {
            final updatedProfile = profile.copyWith(name: newName);
            final result = await _profileRepository.updateUserProfile(updatedProfile);
            result.fold(
              (failure) {
                emit(currentState.copyWith(name: previousName));
              },
              (_) => null,
            );
          },
        );
      }
    }
  }
}
