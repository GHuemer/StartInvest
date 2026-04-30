import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password);
  Future<Either<Failure, void>> signOut();
  Stream<AppUser?> get authStateChanges;
}
