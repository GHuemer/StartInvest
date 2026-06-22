import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignUp {
  const SignUp(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AppUser>> call({
    required String username,
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
  }) => _repository.signUp(
    username: username,
    name: name,
    email: email,
    password: password,
    birthDate: birthDate,
  );
}
