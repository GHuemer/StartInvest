import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet.dart';
import '../entities/position.dart';
import '../entities/trade.dart';
import '../entities/market_asset.dart';

abstract class PortfolioRepository {
  Future<Either<Failure, List<Wallet>>> getWallets();
  Future<Either<Failure, Wallet>> createWallet(
    String name,
    double startingBalance,
  );
  Future<Either<Failure, List<Position>>> getPositions(String walletId);
  Future<Either<Failure, List<Trade>>> getTrades(String walletId);
  Future<Either<Failure, Trade>> buyAsset({
    required String walletId,
    required String ticker,
    required AssetType assetType,
    required double quantity,
    required double price,
  });
  Future<Either<Failure, Trade>> sellAsset({
    required String walletId,
    required String ticker,
    required double quantity,
    required double price,
    required int xpEarned,
  });
  Future<Either<Failure, MarketAsset>> getAssetPrice(
    String ticker,
    AssetType type,
  );
  Future<Either<Failure, List<MarketAsset>>> getAssetsByType(AssetType type);
  Future<Either<Failure, List<MarketAsset>>> searchAssets(
    String query,
    AssetType type,
  );
  Future<Either<Failure, void>> deleteWallet(String walletId);
}
