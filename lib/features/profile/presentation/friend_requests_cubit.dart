import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../domain/repositories/profile_repository.dart';

part 'friend_requests_state.dart';

@injectable
class FriendRequestsCubit extends Cubit<FriendRequestsState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  StreamSubscription? _subscription;
  StreamSubscription? _authSubscription;

  FriendRequestsCubit(this._profileRepository, this._authRepository)
    : super(FriendRequestsInitial()) {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _initForUser(user.id);
      } else {
        _cleanup();
        emit(FriendRequestsInitial());
      }
    });
  }

  void _initForUser(String userId) {
    _subscription?.cancel();
    _subscription = _profileRepository.watchFriendRequests(userId).listen((
      requests,
    ) {
      emit(FriendRequestsLoaded(requests));
    });
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> acceptRequest(String requestId) async {
    final result = await _profileRepository.respondToFriendRequest(
      requestId,
      true,
    );
    result.fold((failure) => null, (_) => null);
  }

  Future<void> declineRequest(String requestId) async {
    final result = await _profileRepository.respondToFriendRequest(
      requestId,
      false,
    );
    result.fold((failure) => null, (_) => null);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
