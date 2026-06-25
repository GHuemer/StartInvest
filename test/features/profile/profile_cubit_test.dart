import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/auth/domain/entities/user.dart';
import 'package:startinvest/features/auth/domain/repositories/auth_repository.dart';
import 'package:startinvest/features/profile/domain/entities/user_profile.dart';
import 'package:startinvest/features/profile/domain/repositories/profile_repository.dart';
import 'package:startinvest/features/profile/presentation/profile_cubit.dart';
import 'package:startinvest/features/profile/presentation/profile_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository auth;
  late MockProfileRepository profile;

  const user = AppUser(id: 'u1', username: 'joao', name: 'Joao', email: 'e');

  const userProfile = UserProfile(
    id: 'u1',
    username: 'joao',
    name: 'Joao',
    email: 'e',
    xp: 100,
    level: 2,
    league: 'prata',
    subtitle: 's',
    completedCoursesCount: 1,
    balance: 1000,
    assetTypesCount: 1,
    loginStreak: 4,
    completedMissionsIds: [],
    friendIds: ['f1', 'f2'],
    memberSince: '2024',
  );

  setUpAll(() => registerFallbackValue(userProfile));
  setUp(() {
    auth = MockAuthRepository();
    profile = MockProfileRepository();
  });

  ProfileCubit build() => ProfileCubit(auth, profile);

  test('estado inicial', () {
    expect(build().state, const ProfileInitial());
  });

  blocTest<ProfileCubit, ProfileState>(
    'loadProfile emite ProfileError quando nao ha usuario autenticado',
    setUp: () => when(() => auth.currentUser).thenReturn(null),
    build: build,
    act: (cubit) => cubit.loadProfile(),
    expect: () => [const ProfileLoading(), isA<ProfileError>()],
  );

  blocTest<ProfileCubit, ProfileState>(
    'loadProfile emite ProfileLoaded com os dados do perfil',
    setUp: () {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profile.getUserProfile('u1'))
          .thenAnswer((_) async => const Right(userProfile));
    },
    build: build,
    act: (cubit) => cubit.loadProfile(),
    expect: () => [
      const ProfileLoading(),
      isA<ProfileLoaded>()
          .having((s) => s.name, 'name', 'Joao')
          .having((s) => s.friendsCount, 'friendsCount', 2)
          .having((s) => s.xp, 'xp', 100),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'loadProfile emite ProfileError quando o repositorio falha',
    setUp: () {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profile.getUserProfile('u1'))
          .thenAnswer((_) async => const Left(ServerFailure('erro')));
    },
    build: build,
    act: (cubit) => cubit.loadProfile(),
    expect: () => [const ProfileLoading(), isA<ProfileError>()],
  );

  blocTest<ProfileCubit, ProfileState>(
    'logout delega o signOut ao AuthRepository',
    setUp: () => when(() => auth.signOut())
        .thenAnswer((_) async => const Right<Failure, void>(null)),
    build: build,
    act: (cubit) => cubit.logout(),
    verify: (_) => verify(() => auth.signOut()).called(1),
  );
}
