import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/auth/domain/entities/user.dart';
import 'package:startinvest/features/auth/domain/repositories/auth_repository.dart';
import 'package:startinvest/features/profile/domain/repositories/profile_repository.dart';
import 'package:startinvest/features/profile/presentation/friend_requests_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository auth;
  late MockProfileRepository profile;
  late StreamController<AppUser?> authController;
  late StreamController<List<Map<String, dynamic>>> requestsController;

  const user = AppUser(id: 'u1', username: 'joao', name: 'Joao', email: 'e');

  setUp(() {
    auth = MockAuthRepository();
    profile = MockProfileRepository();
    authController = StreamController<AppUser?>.broadcast();
    requestsController =
        StreamController<List<Map<String, dynamic>>>.broadcast();

    when(() => auth.authStateChanges).thenAnswer((_) => authController.stream);
    when(() => profile.watchFriendRequests(any()))
        .thenAnswer((_) => requestsController.stream);
  });

  tearDown(() {
    authController.close();
    requestsController.close();
  });

  test('estado inicial e FriendRequestsInitial', () {
    final cubit = FriendRequestsCubit(profile, auth);
    expect(cubit.state, isA<FriendRequestsInitial>());
    cubit.close();
  });

  test('emite FriendRequestsLoaded quando ha usuario e chegam solicitacoes',
      () async {
    final cubit = FriendRequestsCubit(profile, auth);

    final expectation = expectLater(
      cubit.stream,
      emitsThrough(isA<FriendRequestsLoaded>()
          .having((s) => s.requests.length, 'requests', 1)),
    );

    authController.add(user);
    await Future<void>.delayed(Duration.zero);
    requestsController.add([
      {'id': 'r1', 'fromName': 'Maria'}
    ]);

    await expectation;
    cubit.close();
  });

  test('volta para Initial quando o usuario faz logout (null)', () async {
    final cubit = FriendRequestsCubit(profile, auth);
    authController.add(user);
    await Future<void>.delayed(Duration.zero);

    final expectation = expectLater(
      cubit.stream,
      emitsThrough(isA<FriendRequestsInitial>()),
    );
    authController.add(null);
    await expectation;
    cubit.close();
  });

  test('acceptRequest delega ao repository com accept=true', () async {
    when(() => profile.respondToFriendRequest(any(), any()))
        .thenAnswer((_) async => const Right<Failure, void>(null));
    final cubit = FriendRequestsCubit(profile, auth);

    await cubit.acceptRequest('r1');

    verify(() => profile.respondToFriendRequest('r1', true)).called(1);
    cubit.close();
  });

  test('declineRequest delega ao repository com accept=false', () async {
    when(() => profile.respondToFriendRequest(any(), any()))
        .thenAnswer((_) async => const Right<Failure, void>(null));
    final cubit = FriendRequestsCubit(profile, auth);

    await cubit.declineRequest('r1');

    verify(() => profile.respondToFriendRequest('r1', false)).called(1);
    cubit.close();
  });
}
