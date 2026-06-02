import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AppUser>> call(String name, String email, String password) =>
      _repository.signUp(name, email, password);
}
