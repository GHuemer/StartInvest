import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/auth/domain/entities/user.dart';
import 'package:startinvest/features/auth/domain/repositories/auth_repository.dart';
import 'package:startinvest/features/auth/domain/usecases/sign_in_email.dart';
import 'package:startinvest/features/auth/domain/usecases/sign_in_google.dart';
import 'package:startinvest/features/auth/domain/usecases/sign_out.dart';
import 'package:startinvest/features/auth/presentation/bloc/auth_bloc.dart';

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignOut extends Mock implements SignOut {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignOut mockSignOut;
  late MockAuthRepository mockAuthRepository;

  final tUser = AppUser(id: '1', name: 'Test User', email: 'test@test.com');
  const tEmail = 'test@test.com';
  const tPassword = '123456';

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignOut = MockSignOut();
    mockAuthRepository = MockAuthRepository();

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    authBloc = AuthBloc(
      signInWithGoogle: mockSignInWithGoogle,
      signInWithEmail: mockSignInWithEmail,
      signOut: mockSignOut,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('O estado inicial deve ser AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading] quando AuthStarted for adicionado',
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const AuthLoading()],
    );
  });

  group('AuthUserChanged', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthAuthenticated] quando o usuario nao for nulo',
      build: () => authBloc,
      act: (bloc) => bloc.add(AuthUserChanged(tUser)),
      expect: () => [AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthUnauthenticated] quando o usuario for nulo',
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthUserChanged(null)),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('AuthSignInWithGoogle', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthAuthenticated] em caso de sucesso',
      build: () {
        when(() => mockSignInWithGoogle())
            .thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthError] em caso de falha',
      build: () {
        when(() => mockSignInWithGoogle()).thenAnswer(
            (_) async => const Left(AuthFailure('Erro ao logar com Google')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError('Erro ao logar com Google'),
      ],
    );
  });

  group('AuthSignInWithEmail', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthAuthenticated] em caso de sucesso',
      build: () {
        when(() => mockSignInWithEmail(tEmail, tPassword))
            .thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
          const AuthSignInWithEmailRequested(email: tEmail, password: tPassword)),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthError] em caso de falha',
      build: () {
        when(() => mockSignInWithEmail(tEmail, tPassword)).thenAnswer(
            (_) async => const Left(AuthFailure('Credenciais invalidas')));
        return authBloc;
      },
      act: (bloc) => bloc.add(
          const AuthSignInWithEmailRequested(email: tEmail, password: tPassword)),
      expect: () => [
        const AuthLoading(),
        const AuthError('Credenciais invalidas'),
      ],
    );
  });

  group('AuthSignOut', () {
    blocTest<AuthBloc, AuthState>(
      'deve chamar SignOut e emitir [AuthUnauthenticated]',
      build: () {
        when(() => mockSignOut())
            .thenAnswer((_) async => const Right<Failure, void>(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) {
        verify(() => mockSignOut()).called(1);
      },
    );
  });
}
