import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class DeleteWalletUseCase {
  final PortfolioRepository _repository;
  DeleteWalletUseCase(this._repository);

  Future<Either<Failure, void>> call(String walletId) =>
      _repository.deleteWallet(walletId);
}
