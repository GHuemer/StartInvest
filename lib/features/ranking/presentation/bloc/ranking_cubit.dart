import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'ranking_state.dart';

@injectable
class RankingCubit extends Cubit<RankingState> {
  final ProfileRepository _profileRepository;
  final AuthBloc _authBloc;

  RankingCubit(this._profileRepository, this._authBloc) : super(const RankingInitial());

  Future<void> loadRankings() async {
    emit(const RankingLoading());

    // Obter IDs de amigos do perfil do usuário atual
    final authState = _authBloc.state;
    List<String> friendIds = [];
    UserProfile? currentUserProfile;

    if (authState is AuthAuthenticated) {
      final userResult = await _profileRepository.getUserProfile(authState.user.id);
      userResult.fold(
        (_) => null,
        (profile) {
          currentUserProfile = profile;
          friendIds = List<String>.from(profile.friendIds);
        },
      );
    }

    final globalResult = await _profileRepository.getRanking();
    
    // Adicionar o próprio usuário na lista de IDs para o ranking de amigos
    if (authState is AuthAuthenticated && !friendIds.contains(authState.user.id)) {
      friendIds.add(authState.user.id);
    }

    final friendsResult = await _profileRepository.getFriendsRanking(friendIds);

    globalResult.fold(
      (failure) => emit(RankingError(failure.toString())),
      (globalRanking) {
        friendsResult.fold(
          (failure) => emit(RankingError(failure.toString())),
          (friendsRanking) => emit(RankingLoaded(
            globalRanking: globalRanking,
            friendsRanking: friendsRanking,
          )),
        );
      },
    );
  }

  Future<Either<String, void>> addFriendByUsername(String username) async {
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) return const Left('Usuário não autenticado');

    final searchResult = await _profileRepository.searchUserByName(username);
    
    return searchResult.fold(
      (failure) => Left(failure.toString()),
      (friendProfile) async {
        if (friendProfile == null) return const Left('Usuário não encontrado');
        if (friendProfile.id == authState.user.id) {
          return const Left('Você não pode adicionar a si mesmo');
        }
        
        // Verifica se já é amigo
        final userResult = await _profileRepository.getUserProfile(authState.user.id);
        final alreadyFriend = userResult.fold(
          (_) => false,
          (profile) => profile.friendIds.contains(friendProfile.id),
        );

        if (alreadyFriend) return const Left('Este usuário já é seu amigo');

        final addResult = await _profileRepository.addFriend(authState.user.id, friendProfile.id);
        
        return addResult.fold(
          (failure) => Left(failure.toString()),
          (_) async {
            await loadRankings(); // Atualiza a lista após adicionar
            return const Right(null);
          },
        );
      },
    );
  }
}
