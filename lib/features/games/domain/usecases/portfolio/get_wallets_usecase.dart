import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/wallet.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class GetWalletsUseCase {
  final PortfolioRepository _repository;
  GetWalletsUseCase(this._repository);

  Future<Either<Failure, List<Wallet>>> call() => _repository.getWallets();
}
