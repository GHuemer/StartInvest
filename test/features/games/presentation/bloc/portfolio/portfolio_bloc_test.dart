import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/trade.dart';
import 'package:startinvest/features/games/domain/entities/wallet.dart';
import 'package:startinvest/features/games/domain/repositories/portfolio_repository.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/buy_asset_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/create_wallet_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/delete_wallet_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/get_positions_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/get_trades_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/get_wallets_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/sell_asset_usecase.dart';
import 'package:startinvest/features/games/presentation/bloc/portfolio/portfolio_bloc.dart';
import 'package:startinvest/features/games/presentation/bloc/portfolio/portfolio_event.dart';
import 'package:startinvest/features/games/presentation/bloc/portfolio/portfolio_state.dart';

class MockGetWalletsUseCase extends Mock implements GetWalletsUseCase {}
class MockCreateWalletUseCase extends Mock implements CreateWalletUseCase {}
class MockGetPositionsUseCase extends Mock implements GetPositionsUseCase {}
class MockBuyAssetUseCase extends Mock implements BuyAssetUseCase {}
class MockSellAssetUseCase extends Mock implements SellAssetUseCase {}
class MockGetTradesUseCase extends Mock implements GetTradesUseCase {}
class MockDeleteWalletUseCase extends Mock implements DeleteWalletUseCase {}
class MockPortfolioRepository extends Mock implements PortfolioRepository {}

Wallet _makeWallet({String id = 'wallet-1'}) => Wallet(
      id: id,
      userId: 'user-1',
      name: 'Minha carteira',
      startingBalance: 5000,
      availableBalance: 5000,
      createdAt: DateTime(2024),
    );

Trade _makeTrade({TradeType type = TradeType.buy, int? xpEarned}) => Trade(
      id: 'trade-1',
      walletId: 'wallet-1',
      ticker: 'PETR4',
      assetType: AssetType.stock,
      type: type,
      quantity: 10,
      price: 30.0,
      totalValue: 300.0,
      timestamp: DateTime(2024),
      xpEarned: xpEarned,
    );

void main() {
  late PortfolioBloc bloc;
  late MockGetWalletsUseCase mockGetWallets;
  late MockCreateWalletUseCase mockCreateWallet;
  late MockGetPositionsUseCase mockGetPositions;
  late MockBuyAssetUseCase mockBuyAsset;
  late MockSellAssetUseCase mockSellAsset;
  late MockGetTradesUseCase mockGetTrades;
  late MockDeleteWalletUseCase mockDeleteWallet;
  late MockPortfolioRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AssetType.stock);
  });

  setUp(() {
    mockGetWallets = MockGetWalletsUseCase();
    mockCreateWallet = MockCreateWalletUseCase();
    mockGetPositions = MockGetPositionsUseCase();
    mockBuyAsset = MockBuyAssetUseCase();
    mockSellAsset = MockSellAssetUseCase();
    mockGetTrades = MockGetTradesUseCase();
    mockDeleteWallet = MockDeleteWalletUseCase();
    mockRepository = MockPortfolioRepository();

    bloc = PortfolioBloc(
      mockGetWallets,
      mockCreateWallet,
      mockGetPositions,
      mockBuyAsset,
      mockSellAsset,
      mockGetTrades,
      mockDeleteWallet,
      mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('estado inicial deve ser PortfolioInitial', () {
    expect(bloc.state, const PortfolioInitial());
  });

  group('LoadWallets', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, WalletsLoaded] com lista vazia',
      build: () {
        when(() => mockGetWallets()).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (b) => b.add(const LoadWallets()),
      expect: () => [
        const PortfolioLoading(),
        isA<WalletsLoaded>().having((s) => s.wallets, 'wallets', isEmpty),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, WalletsLoaded] com carteiras e posições',
      build: () {
        when(() => mockGetWallets())
            .thenAnswer((_) async => Right([_makeWallet()]));
        when(() => mockGetPositions('wallet-1'))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (b) => b.add(const LoadWallets()),
      expect: () => [
        const PortfolioLoading(),
        isA<WalletsLoaded>()
            .having((s) => s.wallets.length, 'wallets.length', 1),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, PortfolioError] em caso de falha',
      build: () {
        when(() => mockGetWallets())
            .thenAnswer((_) async => const Left(ServerFailure('Sem conexão')));
        return bloc;
      },
      act: (b) => b.add(const LoadWallets()),
      expect: () => [
        const PortfolioLoading(),
        isA<PortfolioError>(),
      ],
    );
  });

  group('CreateWallet', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, WalletCreated] em caso de sucesso',
      build: () {
        when(() => mockCreateWallet(
              name: any(named: 'name'),
              startingBalance: any(named: 'startingBalance'),
              currentWalletCount: any(named: 'currentWalletCount'),
            )).thenAnswer((_) async => Right(_makeWallet()));
        return bloc;
      },
      act: (b) => b.add(const CreateWallet(name: 'Nova', startingBalance: 5000)),
      expect: () => [
        const PortfolioLoading(),
        isA<WalletCreated>(),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, PortfolioError] quando limite de carteiras for atingido',
      build: () {
        when(() => mockCreateWallet(
              name: any(named: 'name'),
              startingBalance: any(named: 'startingBalance'),
              currentWalletCount: any(named: 'currentWalletCount'),
            )).thenAnswer(
          (_) async => const Left(ServerFailure('Limite de 3 carteiras atingido.')),
        );
        return bloc;
      },
      seed: () => WalletsLoaded([
        _makeWallet(id: 'w1'),
        _makeWallet(id: 'w2'),
        _makeWallet(id: 'w3'),
      ]),
      act: (b) => b.add(const CreateWallet(name: 'Quarta', startingBalance: 5000)),
      expect: () => [
        const PortfolioLoading(),
        isA<PortfolioError>().having(
          (s) => s.message,
          'message',
          'Limite de 3 carteiras atingido.',
        ),
      ],
    );
  });

  group('BuyAsset', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, TradeExecuted] em caso de sucesso',
      build: () {
        when(() => mockBuyAsset(
              walletId: any(named: 'walletId'),
              ticker: any(named: 'ticker'),
              assetType: any(named: 'assetType'),
              quantity: any(named: 'quantity'),
              price: any(named: 'price'),
              availableBalance: any(named: 'availableBalance'),
            )).thenAnswer((_) async => Right(_makeTrade()));
        return bloc;
      },
      act: (b) => b.add(const BuyAsset(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 10,
        price: 30.0,
        availableBalance: 500.0,
      )),
      expect: () => [
        const PortfolioLoading(),
        isA<TradeExecuted>()
            .having((s) => s.message, 'message', contains('PETR4'))
            .having((s) => s.xpChange, 'xpChange', 0),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, PortfolioError] em caso de falha',
      build: () {
        when(() => mockBuyAsset(
              walletId: any(named: 'walletId'),
              ticker: any(named: 'ticker'),
              assetType: any(named: 'assetType'),
              quantity: any(named: 'quantity'),
              price: any(named: 'price'),
              availableBalance: any(named: 'availableBalance'),
            )).thenAnswer(
          (_) async => const Left(ServerFailure('Saldo insuficiente para esta compra.')),
        );
        return bloc;
      },
      act: (b) => b.add(const BuyAsset(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 100,
        price: 30.0,
        availableBalance: 100.0,
      )),
      expect: () => [
        const PortfolioLoading(),
        isA<PortfolioError>(),
      ],
    );
  });

  group('SellAsset', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, TradeExecuted] com XP positivo',
      build: () {
        when(() => mockSellAsset(
              walletId: any(named: 'walletId'),
              ticker: any(named: 'ticker'),
              assetType: any(named: 'assetType'),
              quantity: any(named: 'quantity'),
              price: any(named: 'price'),
              avgBuyPrice: any(named: 'avgBuyPrice'),
              ownedQuantity: any(named: 'ownedQuantity'),
            )).thenAnswer((_) async => Right(_makeTrade(type: TradeType.sell, xpEarned: 75)));
        return bloc;
      },
      act: (b) => b.add(const SellAsset(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 5,
        price: 35.0,
        avgBuyPrice: 30.0,
        ownedQuantity: 10,
      )),
      expect: () => [
        const PortfolioLoading(),
        isA<TradeExecuted>()
            .having((s) => s.xpChange, 'xpChange', 75)
            .having((s) => s.message, 'message', contains('+75 XP')),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, PortfolioError] em caso de falha',
      build: () {
        when(() => mockSellAsset(
              walletId: any(named: 'walletId'),
              ticker: any(named: 'ticker'),
              assetType: any(named: 'assetType'),
              quantity: any(named: 'quantity'),
              price: any(named: 'price'),
              avgBuyPrice: any(named: 'avgBuyPrice'),
              ownedQuantity: any(named: 'ownedQuantity'),
            )).thenAnswer(
          (_) async => const Left(ServerFailure('Quantidade inválida para venda.')),
        );
        return bloc;
      },
      act: (b) => b.add(const SellAsset(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 100,
        price: 35.0,
        avgBuyPrice: 30.0,
        ownedQuantity: 5,
      )),
      expect: () => [
        const PortfolioLoading(),
        isA<PortfolioError>(),
      ],
    );
  });

  group('LoadTrades', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, TradesLoaded] em caso de sucesso',
      build: () {
        when(() => mockGetTrades('wallet-1'))
            .thenAnswer((_) async => Right([_makeTrade()]));
        return bloc;
      },
      act: (b) => b.add(const LoadTrades('wallet-1')),
      expect: () => [
        const PortfolioLoading(),
        isA<TradesLoaded>().having((s) => s.trades.length, 'trades.length', 1),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, PortfolioError] em caso de falha',
      build: () {
        when(() => mockGetTrades(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Erro')));
        return bloc;
      },
      act: (b) => b.add(const LoadTrades('wallet-1')),
      expect: () => [
        const PortfolioLoading(),
        isA<PortfolioError>(),
      ],
    );
  });

  group('DeleteWallet', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, WalletDeleted] em caso de sucesso',
      build: () {
        when(() => mockDeleteWallet('wallet-1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(const DeleteWallet('wallet-1')),
      expect: () => [
        const PortfolioLoading(),
        const WalletDeleted(),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'deve emitir [PortfolioLoading, PortfolioError] em caso de falha',
      build: () {
        when(() => mockDeleteWallet(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Não foi possível deletar')));
        return bloc;
      },
      act: (b) => b.add(const DeleteWallet('wallet-1')),
      expect: () => [
        const PortfolioLoading(),
        isA<PortfolioError>(),
      ],
    );
  });
}
