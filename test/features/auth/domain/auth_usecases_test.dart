import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/auth/domain/entities/user.dart';
import 'package:startinvest/features/auth/domain/repositories/auth_repository.dart';
import 'package:startinvest/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:startinvest/features/auth/domain/usecases/sign_in_email.dart';
import 'package:startinvest/features/auth/domain/usecases/sign_in_google.dart';
import 'package:startinvest/features/auth/domain/usecases/sign_out.dart';
import 'package:startinvest/features/auth/domain/usecases/sign_up.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const tUser = AppUser(
    id: 'u1',
    username: 'joao',
    name: 'Joao',
    email: 'joao@test.com',
  );

  setUp(() => repository = MockAuthRepository());

  group('SendPasswordResetEmail', () {
    test('delega ao repository e retorna Right', () async {
      when(() => repository.sendPasswordResetEmail(any()))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await SendPasswordResetEmail(repository)('a@b.com');

      expect(result.isRight(), true);
      verify(() => repository.sendPasswordResetEmail('a@b.com')).called(1);
    });

    test('propaga Left em caso de falha', () async {
      when(() => repository.sendPasswordResetEmail(any()))
          .thenAnswer((_) async => const Left(ServerFailure('erro')));

      final result = await SendPasswordResetEmail(repository)('a@b.com');

      expect(result.isLeft(), true);
    });
  });

  group('SignInWithEmail', () {
    test('delega ao repository e retorna o usuario', () async {
      when(() => repository.signInWithEmail(any(), any()))
          .thenAnswer((_) async => const Right(tUser));

      final result = await SignInWithEmail(repository)('a@b.com', '123456');

      expect(result, const Right<Failure, AppUser>(tUser));
      verify(() => repository.signInWithEmail('a@b.com', '123456')).called(1);
    });
  });

  group('SignInWithGoogle', () {
    test('delega ao repository', () async {
      when(() => repository.signInWithGoogle())
          .thenAnswer((_) async => const Right(tUser));

      final result = await SignInWithGoogle(repository)();

      expect(result, const Right<Failure, AppUser>(tUser));
      verify(() => repository.signInWithGoogle()).called(1);
    });
  });

  group('SignOut', () {
    test('delega ao repository', () async {
      when(() => repository.signOut())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await SignOut(repository)();

      expect(result.isRight(), true);
      verify(() => repository.signOut()).called(1);
    });
  });

  group('SignUp', () {
    test('delega ao repository com todos os campos', () async {
      when(() => repository.signUp(
            username: any(named: 'username'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            birthDate: any(named: 'birthDate'),
          )).thenAnswer((_) async => const Right(tUser));

      final birthDate = DateTime(2000, 1, 1);
      final result = await SignUp(repository)(
        username: 'joao',
        name: 'Joao',
        email: 'joao@test.com',
        password: '123456',
        birthDate: birthDate,
      );

      expect(result, const Right<Failure, AppUser>(tUser));
      verify(() => repository.signUp(
            username: 'joao',
            name: 'Joao',
            email: 'joao@test.com',
            password: '123456',
            birthDate: birthDate,
          )).called(1);
    });
  });

  group('AppUser entity', () {
    test('valores padrao sao aplicados', () {
      expect(tUser.xp, 0);
      expect(tUser.level, 1);
      expect(tUser.league, 'bronze');
      expect(tUser.isNewUser, false);
    });

    test('copyWith altera apenas os campos informados', () {
      final updated = tUser.copyWith(xp: 100, level: 2, name: 'Novo');

      expect(updated.xp, 100);
      expect(updated.level, 2);
      expect(updated.name, 'Novo');
      expect(updated.id, tUser.id);
      expect(updated.email, tUser.email);
    });

    test('igualdade por valor (Equatable)', () {
      expect(tUser, const AppUser(
        id: 'u1',
        username: 'joao',
        name: 'Joao',
        email: 'joao@test.com',
      ));
    });
  });
}
