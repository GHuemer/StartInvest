import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/auth/domain/entities/user.dart';
import 'package:startinvest/features/auth/domain/repositories/auth_repository.dart';
import 'package:startinvest/features/profile/domain/entities/user_profile.dart';
import 'package:startinvest/features/profile/domain/repositories/profile_repository.dart';
import 'package:startinvest/features/ranking/presentation/bloc/ranking_cubit.dart';
import 'package:startinvest/features/ranking/presentation/bloc/ranking_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository auth;
  late MockProfileRepository profile;

  const user = AppUser(id: 'u1', username: 'joao', name: 'Joao', email: 'e');

  UserProfile profileWith(String id, {List<String> friends = const []}) =>
      UserProfile(
        id: id,
        username: id,
        name: id,
        email: 'e',
        xp: 100,
        level: 2,
        league: 'prata',
        subtitle: 's',
        completedCoursesCount: 0,
        balance: 0,
        assetTypesCount: 0,
        loginStreak: 0,
        completedMissionsIds: const [],
        friendIds: friends,
        memberSince: '2024',
      );

  setUp(() {
    auth = MockAuthRepository();
    profile = MockProfileRepository();
  });

  RankingCubit build() => RankingCubit(profile, auth);

  group('loadRankings', () {
    blocTest<RankingCubit, RankingState>(
      'emite RankingError quando nao ha usuario',
      setUp: () => when(() => auth.currentUser).thenReturn(null),
      build: build,
      act: (cubit) => cubit.loadRankings(),
      expect: () => [const RankingLoading(), isA<RankingError>()],
    );

    blocTest<RankingCubit, RankingState>(
      'emite RankingLoaded com rankings global e de amigos',
      setUp: () {
        when(() => auth.currentUser).thenReturn(user);
        when(() => profile.getUserProfile('u1')).thenAnswer(
            (_) async => Right(profileWith('u1', friends: ['f1'])));
        when(() => profile.getRanking()).thenAnswer(
            (_) async => Right([profileWith('u1'), profileWith('f1')]));
        when(() => profile.getFriendsRanking(any())).thenAnswer(
            (_) async => Right([profileWith('u1'), profileWith('f1')]));
      },
      build: build,
      act: (cubit) => cubit.loadRankings(),
      expect: () => [
        const RankingLoading(),
        isA<RankingLoaded>()
            .having((s) => s.globalRanking.length, 'global', 2)
            .having((s) => s.friendsRanking.length, 'friends', 2),
      ],
    );

    blocTest<RankingCubit, RankingState>(
      'emite RankingError quando getUserProfile falha',
      setUp: () {
        when(() => auth.currentUser).thenReturn(user);
        when(() => profile.getUserProfile('u1'))
            .thenAnswer((_) async => const Left(ServerFailure('erro')));
      },
      build: build,
      act: (cubit) => cubit.loadRankings(),
      expect: () => [const RankingLoading(), isA<RankingError>()],
    );
  });

  group('sendFriendRequestByUsername', () {
    test('retorna Left quando nao ha usuario autenticado', () async {
      when(() => auth.currentUser).thenReturn(null);
      final result = await build().sendFriendRequestByUsername('alvo');
      expect(result.isLeft(), true);
    });

    test('retorna Left quando o usuario alvo nao existe', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profile.searchUserByName('alvo'))
          .thenAnswer((_) async => const Right(null));
      final result = await build().sendFriendRequestByUsername('alvo');
      expect(result.isLeft(), true);
    });

    test('retorna Left ao tentar adicionar a si mesmo', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profile.searchUserByName(any()))
          .thenAnswer((_) async => Right(profileWith('u1')));
      final result = await build().sendFriendRequestByUsername('joao');
      expect(result.isLeft(), true);
    });

    test('retorna Left quando ja sao amigos', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profile.searchUserByName(any()))
          .thenAnswer((_) async => Right(profileWith('f1')));
      when(() => profile.getUserProfile('u1')).thenAnswer(
          (_) async => Right(profileWith('u1', friends: ['f1'])));
      final result = await build().sendFriendRequestByUsername('f1');
      expect(result.isLeft(), true);
    });

    test('retorna Right quando a solicitacao e enviada', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profile.searchUserByName(any()))
          .thenAnswer((_) async => Right(profileWith('f1')));
      when(() => profile.getUserProfile('u1'))
          .thenAnswer((_) async => Right(profileWith('u1')));
      when(() => profile.sendFriendRequest('u1', 'f1'))
          .thenAnswer((_) async => const Right<Failure, void>(null));
      final result = await build().sendFriendRequestByUsername('f1');
      expect(result.isRight(), true);
    });
  });
}
