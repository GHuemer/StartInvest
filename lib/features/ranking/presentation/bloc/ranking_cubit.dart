import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'ranking_state.dart';

@injectable
class RankingCubit extends Cubit<RankingState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  RankingCubit(this._profileRepository, this._authRepository)
    : super(const RankingInitial());

  Future<void> loadRankings() async {
    emit(const RankingLoading());

    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        emit(const RankingError('Usuário não autenticado'));
        return;
      }

      // 1. Buscar Perfil Atualizado do Usuário
      final userResult = await _profileRepository.getUserProfile(user.id);
      final profile = userResult.fold((l) => throw l, (r) => r);

      // Garante que o ID do usuário atual está na lista para o ranking de amigos
      final Set<String> idsToFetch = Set.from(profile.friendIds);
      idsToFetch.add(profile.id);

      // 2. Buscar Rankings em paralelo
      final results = await Future.wait([
        _profileRepository.getRanking(),
        _profileRepository.getFriendsRanking(idsToFetch.toList()),
      ]);

      final globalRanking = results[0].fold((l) => throw l, (r) => r);
      final friendsRanking = results[1].fold((l) => throw l, (r) => r);

      emit(
        RankingLoaded(
          globalRanking: globalRanking,
          friendsRanking: friendsRanking,
        ),
      );
    } catch (e) {
      emit(RankingError(e.toString()));
    }
  }

  Future<Either<String, void>> sendFriendRequestByUsername(
    String username,
  ) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) return const Left('Usuário não autenticado');

      // 1. Buscar usuário pelo username
      final searchResult = await _profileRepository.searchUserByName(username);
      final friendProfile = searchResult.fold((l) => throw l, (r) => r);

      if (friendProfile == null) return const Left('Usuário não encontrado');
      if (friendProfile.id == user.id) {
        return const Left('Você não pode adicionar a si mesmo');
      }

      // 2. Verificar se já são amigos
      final userResult = await _profileRepository.getUserProfile(user.id);
      final currentUserProfile = userResult.fold((l) => throw l, (r) => r);

      if (currentUserProfile.friendIds.contains(friendProfile.id)) {
        return const Left('Este usuário já é seu amigo');
      }

      // 3. Enviar solicitação
      final requestResult = await _profileRepository.sendFriendRequest(
        user.id,
        friendProfile.id,
      );
      return requestResult.leftMap((f) => f.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }
}
