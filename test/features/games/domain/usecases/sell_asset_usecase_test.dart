import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/trade.dart';
import 'package:startinvest/features/games/domain/repositories/portfolio_repository.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/calculate_portfolio_xp_usecase.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/sell_asset_usecase.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late SellAssetUseCase useCase;
  late MockPortfolioRepository mockRepository;
  late CalculatePortfolioXpUseCase calculateXp;

  final tTrade = Trade(
    id: 'trade-2',
    walletId: 'wallet-1',
    ticker: 'PETR4',
    assetType: AssetType.stock,
    type: TradeType.sell,
    quantity: 5,
    price: 35.0,
    totalValue: 175.0,
    timestamp: DateTime(2024),
    xpEarned: 50,
  );

  setUp(() {
    mockRepository = MockPortfolioRepository();
    calculateXp = CalculatePortfolioXpUseCase();
    useCase = SellAssetUseCase(mockRepository, calculateXp);
  });

  group('SellAssetUseCase - validação de quantidade', () {
    test('deve retornar ServerFailure quando quantidade for zero', () async {
      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 0,
        price: 35.0,
        avgBuyPrice: 30.0,
        ownedQuantity: 10,
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Quantidade inválida para venda.'),
        (_) => fail('deveria ter retornado Left'),
      );
    });

    test('deve retornar ServerFailure quando quantidade superar posse', () async {
      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 15,
        price: 35.0,
        avgBuyPrice: 30.0,
        ownedQuantity: 10,
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Quantidade inválida para venda.'),
        (_) => fail('deveria ter retornado Left'),
      );
    });
  });

  group('SellAssetUseCase - cálculo de XP', () {
    test('deve calcular XP correto para lucro de ação acima de 10%', () async {
      // preço compra 30, venda 35 → lucro de 16.67% → XP 75 para stock
      when(() => mockRepository.sellAsset(
            walletId: 'wallet-1',
            ticker: 'PETR4',
            quantity: 5,
            price: 35.0,
            xpEarned: 75,
          )).thenAnswer((_) async => Right(tTrade));

      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 5,
        price: 35.0,
        avgBuyPrice: 30.0,
        ownedQuantity: 10,
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.sellAsset(
            walletId: 'wallet-1',
            ticker: 'PETR4',
            quantity: 5,
            price: 35.0,
            xpEarned: 75,
          )).called(1);
    });

    test('deve calcular XP correto para lucro zero (avgBuyPrice igual ao preço)', () async {
      // preço compra == venda → 0% → XP 50 para stock
      when(() => mockRepository.sellAsset(
            walletId: 'wallet-1',
            ticker: 'PETR4',
            quantity: 5,
            price: 30.0,
            xpEarned: 50,
          )).thenAnswer((_) async => Right(tTrade));

      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 5,
        price: 30.0,
        avgBuyPrice: 30.0,
        ownedQuantity: 10,
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.sellAsset(
            walletId: 'wallet-1',
            ticker: 'PETR4',
            quantity: 5,
            price: 30.0,
            xpEarned: 50,
          )).called(1);
    });

    test('deve retornar 0 de XP para renda fixa com prejuízo', () async {
      // renda fixa com pct negativo → XP 0
      when(() => mockRepository.sellAsset(
            walletId: 'wallet-1',
            ticker: 'TESOURO',
            quantity: 1,
            price: 90.0,
            xpEarned: 0,
          )).thenAnswer((_) async => Right(tTrade));

      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'TESOURO',
        assetType: AssetType.fixedIncome,
        quantity: 1,
        price: 90.0,
        avgBuyPrice: 100.0,
        ownedQuantity: 1,
      );

      expect(result.isRight(), true);
      verify(() => mockRepository.sellAsset(
            walletId: 'wallet-1',
            ticker: 'TESOURO',
            quantity: 1,
            price: 90.0,
            xpEarned: 0,
          )).called(1);
    });

    test('deve usar profitLossPct 0 quando avgBuyPrice for zero', () async {
      // avgBuyPrice 0 → profitLossPct = 0.0 → XP 50 para stock
      when(() => mockRepository.sellAsset(
            walletId: 'wallet-1',
            ticker: 'PETR4',
            quantity: 5,
            price: 35.0,
            xpEarned: 50,
          )).thenAnswer((_) async => Right(tTrade));

      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 5,
        price: 35.0,
        avgBuyPrice: 0,
        ownedQuantity: 10,
      );

      expect(result.isRight(), true);
    });
  });

  group('SellAssetUseCase - propagação de erros do repository', () {
    test('deve propagar Failure do repository', () async {
      when(() => mockRepository.sellAsset(
            walletId: any(named: 'walletId'),
            ticker: any(named: 'ticker'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            xpEarned: any(named: 'xpEarned'),
          )).thenAnswer((_) async => const Left(ServerFailure('Falha ao vender')));

      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 5,
        price: 35.0,
        avgBuyPrice: 30.0,
        ownedQuantity: 10,
      );

      expect(result.isLeft(), true);
    });
  });
}
