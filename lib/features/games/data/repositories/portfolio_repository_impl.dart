import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/trade.dart';
import '../../domain/entities/market_asset.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/market_api_datasource.dart';
import '../datasources/portfolio_firestore_datasource.dart';

@LazySingleton(as: PortfolioRepository)
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioFirestoreDataSource _firestore;
  final MarketApiDataSource _market;

  PortfolioRepositoryImpl(this._firestore, this._market);

  @override
  Future<Either<Failure, List<Wallet>>> getWallets() async {
    try {
      final wallets = await _firestore.getWallets();
      return Right(wallets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> createWallet(
    String name,
    double startingBalance,
  ) async {
    try {
      final wallet = await _firestore.createWallet(name, startingBalance);
      return Right(wallet);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Position>>> getPositions(String walletId) async {
    try {
      final positions = await _firestore.getPositions(walletId);
      return Right(positions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Trade>>> getTrades(String walletId) async {
    try {
      final trades = await _firestore.getTrades(walletId);
      return Right(trades);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trade>> buyAsset({
    required String walletId,
    required String ticker,
    required AssetType assetType,
    required double quantity,
    required double price,
  }) async {
    try {
      final trade = await _firestore.buyAsset(
        walletId: walletId,
        ticker: ticker,
        assetType: assetType,
        quantity: quantity,
        price: price,
      );
      return Right(trade);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trade>> sellAsset({
    required String walletId,
    required String ticker,
    required double quantity,
    required double price,
    required int xpEarned,
  }) async {
    try {
      final trade = await _firestore.sellAsset(
        walletId: walletId,
        ticker: ticker,
        quantity: quantity,
        price: price,
        xpEarned: xpEarned,
      );
      return Right(trade);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarketAsset>> getAssetPrice(
    String ticker,
    AssetType type,
  ) async {
    try {
      final asset = await _market.getAssetPrice(ticker, type);
      return Right(asset);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketAsset>>> getAssetsByType(
    AssetType type,
  ) async {
    try {
      final assets = await _market.getAssetsByType(type);
      return Right(assets);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketAsset>>> searchAssets(
    String query,
    AssetType type,
  ) async {
    try {
      final assets = await _market.searchAssets(query, type);
      return Right(assets);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWallet(String walletId) async {
    try {
      await _firestore.deleteWallet(walletId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
