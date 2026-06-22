import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/trade.dart';
import '../../entities/position.dart';
import '../../repositories/portfolio_repository.dart';

@injectable
class BuyAssetUseCase {
  final PortfolioRepository _repository;
  BuyAssetUseCase(this._repository);

  Future<Either<Failure, Trade>> call({
    required String walletId,
    required String ticker,
    required AssetType assetType,
    required double quantity,
    required double price,
    required double availableBalance,
  }) async {
    final totalCost = quantity * price;
    if (totalCost > availableBalance) {
      return Left(ServerFailure('Saldo insuficiente para esta compra.'));
    }
    if (quantity <= 0) {
      return Left(ServerFailure('Quantidade deve ser maior que zero.'));
    }
    return _repository.buyAsset(
      walletId: walletId,
      ticker: ticker,
      assetType: assetType,
      quantity: quantity,
      price: price,
    );
  }
}
