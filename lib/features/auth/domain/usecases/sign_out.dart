import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class SignOut {
  const SignOut(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.signOut();
}
