import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/wallet.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class CreateWalletUseCase {
  final PortfolioRepository _repository;
  CreateWalletUseCase(this._repository);

  Future<Either<Failure, Wallet>> call({
    required String name,
    required double startingBalance,
    required int currentWalletCount,
  }) async {
    if (currentWalletCount >= 3) {
      return Left(ServerFailure('Limite de 3 carteiras atingido.'));
    }
    if (startingBalance < 1000 || startingBalance > 100000) {
      return Left(ServerFailure('Saldo deve ser entre R\$1.000 e R\$100.000.'));
    }
    return _repository.createWallet(name, startingBalance);
  }
}
