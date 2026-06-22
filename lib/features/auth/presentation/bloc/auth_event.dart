part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}

class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);
  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

class AuthSignInWithEmailRequested extends AuthEvent {
  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
  });
  final String username;
  final String name;
  final String email;
  final String password;
  final DateTime birthDate;

  @override
  List<Object> get props => [username, name, email, password, birthDate];
}

class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested({required this.email});
  final String email;

  @override
  List<Object> get props => [email];
}
