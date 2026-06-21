import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password);
  Future<Either<Failure, AppUser>> signUp({
    required String username,
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
  });
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> updateUsername(String userId, String username);
  Future<bool> isUsernameAvailable(String username);
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser?> getFullCurrentUser();
}
