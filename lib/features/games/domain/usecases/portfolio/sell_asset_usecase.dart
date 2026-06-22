import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/trade.dart';
import '../../entities/position.dart';
import '../../repositories/portfolio_repository.dart';
import 'calculate_portfolio_xp_usecase.dart';

@injectable
class SellAssetUseCase {
  final PortfolioRepository _repository;
  final CalculatePortfolioXpUseCase _calculateXp;

  SellAssetUseCase(this._repository, this._calculateXp);

  Future<Either<Failure, Trade>> call({
    required String walletId,
    required String ticker,
    required AssetType assetType,
    required double quantity,
    required double price,
    required double avgBuyPrice,
    required double ownedQuantity,
  }) async {
    if (quantity <= 0 || quantity > ownedQuantity) {
      return Left(ServerFailure('Quantidade inválida para venda.'));
    }
    final profitLossPct = avgBuyPrice > 0
        ? ((price - avgBuyPrice) / avgBuyPrice) * 100
        : 0.0;
    final xp = _calculateXp(assetType: assetType, profitLossPct: profitLossPct);
    return _repository.sellAsset(
      walletId: walletId,
      ticker: ticker,
      quantity: quantity,
      price: price,
      xpEarned: xp,
    );
  }
}
