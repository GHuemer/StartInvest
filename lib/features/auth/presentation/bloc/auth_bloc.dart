import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_google.dart';
import '../../domain/usecases/sign_in_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/repositories/auth_repository.dart';

import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithEmail _signInWithEmail;
  final SignOut _signOut;
  final SignUp _signUp;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _authSubscription;

  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithEmail signInWithEmail,
    required SignOut signOut,
    required SignUp signUp,
    required SendPasswordResetEmail sendPasswordResetEmail,
    required AuthRepository authRepository,
  })  : _signInWithGoogle = signInWithGoogle,
        _signInWithEmail = signInWithEmail,
        _signOut = signOut,
        _signUp = signUp,
        _sendPasswordResetEmail = sendPasswordResetEmail,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthRefreshRequested>(_onRefresh);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthForgotPasswordRequested>(_onForgotPassword);

    _authSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = await _authRepository.getFullCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRefresh(AuthRefreshRequested event, Emitter<AuthState> emit) async {
    final user = await _authRepository.getFullCurrentUser();
    if (user != null) {
      // Força a emissão do estado atualizado, o stream de authStateChanges também ajudará
      emit(AuthAuthenticated(user));
    }
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithEmail(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUp(
      username: event.username,
      name: event.name,
      email: event.email,
      password: event.password,
      birthDate: event.birthDate,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSent()),
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
