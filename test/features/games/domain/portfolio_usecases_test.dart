import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/games/domain/entities/market_asset.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/trade.dart';
import 'package:startinvest/features/games/domain/entities/wallet.dart';
import 'package:startinvest/features/games/domain/repositories/portfolio_repository.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/create_wallet_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/delete_wallet_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/get_asset_price_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/get_positions_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/get_trades_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/get_wallets_usecase.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late MockPortfolioRepository repository;

  setUpAll(() => registerFallbackValue(AssetType.stock));
  setUp(() => repository = MockPortfolioRepository());

  group('CreateWalletUseCase', () {
    final wallet = Wallet(
      id: 'w1',
      userId: 'u1',
      name: 'Carteira',
      startingBalance: 5000,
      availableBalance: 5000,
      createdAt: DateTime(2024),
    );

    test('falha quando ja existem 3 carteiras', () async {
      final result = await CreateWalletUseCase(repository)(
        name: 'Nova',
        startingBalance: 5000,
        currentWalletCount: 3,
      );
      expect(result.isLeft(), true);
      verifyNever(() => repository.createWallet(any(), any()));
    });

    test('falha quando saldo abaixo do minimo', () async {
      final result = await CreateWalletUseCase(repository)(
        name: 'Nova',
        startingBalance: 500,
        currentWalletCount: 0,
      );
      expect(result.isLeft(), true);
    });

    test('falha quando saldo acima do maximo', () async {
      final result = await CreateWalletUseCase(repository)(
        name: 'Nova',
        startingBalance: 200000,
        currentWalletCount: 0,
      );
      expect(result.isLeft(), true);
    });

    test('cria carteira quando dados sao validos', () async {
      when(() => repository.createWallet(any(), any()))
          .thenAnswer((_) async => Right(wallet));

      final result = await CreateWalletUseCase(repository)(
        name: 'Nova',
        startingBalance: 5000,
        currentWalletCount: 1,
      );

      expect(result, Right<Failure, Wallet>(wallet));
      verify(() => repository.createWallet('Nova', 5000)).called(1);
    });
  });

  group('DeleteWalletUseCase', () {
    test('delega ao repository', () async {
      when(() => repository.deleteWallet(any()))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await DeleteWalletUseCase(repository)('w1');

      expect(result.isRight(), true);
      verify(() => repository.deleteWallet('w1')).called(1);
    });
  });

  group('GetAssetPriceUseCase', () {
    test('delega ao repository', () async {
      final asset = MarketAsset(
        ticker: 'PETR4',
        name: 'Petrobras',
        type: AssetType.stock,
        currentPrice: 30,
        changePercent: 1,
        fetchedAt: DateTime(2024),
      );
      when(() => repository.getAssetPrice(any(), any()))
          .thenAnswer((_) async => Right(asset));

      final result =
          await GetAssetPriceUseCase(repository)('PETR4', AssetType.stock);

      expect(result, Right<Failure, MarketAsset>(asset));
      verify(() => repository.getAssetPrice('PETR4', AssetType.stock))
          .called(1);
    });
  });

  group('GetPositionsUseCase', () {
    test('delega ao repository', () async {
      when(() => repository.getPositions(any()))
          .thenAnswer((_) async => const Right<Failure, List<Position>>([]));

      final result = await GetPositionsUseCase(repository)('w1');

      expect(result.isRight(), true);
      verify(() => repository.getPositions('w1')).called(1);
    });
  });

  group('GetTradesUseCase', () {
    test('delega ao repository', () async {
      when(() => repository.getTrades(any()))
          .thenAnswer((_) async => const Right<Failure, List<Trade>>([]));

      final result = await GetTradesUseCase(repository)('w1');

      expect(result.isRight(), true);
      verify(() => repository.getTrades('w1')).called(1);
    });
  });

  group('GetWalletsUseCase', () {
    test('delega ao repository', () async {
      when(() => repository.getWallets())
          .thenAnswer((_) async => const Right<Failure, List<Wallet>>([]));

      final result = await GetWalletsUseCase(repository)();

      expect(result.isRight(), true);
      verify(() => repository.getWallets()).called(1);
    });
  });
}
