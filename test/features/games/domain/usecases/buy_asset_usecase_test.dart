import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/core/error/failures.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/trade.dart';
import 'package:startinvest/features/games/domain/repositories/portfolio_repository.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/buy_asset_usecase.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(AssetType.stock);
  });

  late BuyAssetUseCase useCase;
  late MockPortfolioRepository mockRepository;

  final tTrade = Trade(
    id: 'trade-1',
    walletId: 'wallet-1',
    ticker: 'PETR4',
    assetType: AssetType.stock,
    type: TradeType.buy,
    quantity: 10,
    price: 30.0,
    totalValue: 300.0,
    timestamp: DateTime(2024),
  );

  setUp(() {
    mockRepository = MockPortfolioRepository();
    useCase = BuyAssetUseCase(mockRepository);
  });

  group('BuyAssetUseCase', () {
    test('deve retornar ServerFailure quando saldo for insuficiente', () async {
      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 10,
        price: 30.0,
        availableBalance: 100.0, // 10 * 30 = 300 > 100
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Saldo insuficiente para esta compra.'),
        (_) => fail('deveria ter retornado Left'),
      );
      verifyNever(() => mockRepository.buyAsset(
            walletId: any(named: 'walletId'),
            ticker: any(named: 'ticker'),
            assetType: any(named: 'assetType'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
          ));
    });

    test('deve retornar ServerFailure quando quantidade for zero', () async {
      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 0,
        price: 30.0,
        availableBalance: 1000.0,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Quantidade deve ser maior que zero.'),
        (_) => fail('deveria ter retornado Left'),
      );
    });

    test('deve retornar ServerFailure quando quantidade for negativa', () async {
      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: -5,
        price: 30.0,
        availableBalance: 1000.0,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Quantidade deve ser maior que zero.'),
        (_) => fail('deveria ter retornado Left'),
      );
    });

    test('deve chamar repository e retornar Trade em caso de sucesso', () async {
      when(() => mockRepository.buyAsset(
            walletId: 'wallet-1',
            ticker: 'PETR4',
            assetType: AssetType.stock,
            quantity: 10,
            price: 30.0,
          )).thenAnswer((_) async => Right(tTrade));

      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 10,
        price: 30.0,
        availableBalance: 500.0,
      );

      expect(result, Right(tTrade));
      verify(() => mockRepository.buyAsset(
            walletId: 'wallet-1',
            ticker: 'PETR4',
            assetType: AssetType.stock,
            quantity: 10,
            price: 30.0,
          )).called(1);
    });

    test('deve propagar Failure do repository', () async {
      when(() => mockRepository.buyAsset(
            walletId: any(named: 'walletId'),
            ticker: any(named: 'ticker'),
            assetType: any(named: 'assetType'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
          )).thenAnswer((_) async => const Left(ServerFailure('Erro no servidor')));

      final result = await useCase(
        walletId: 'wallet-1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 10,
        price: 30.0,
        availableBalance: 500.0,
      );

      expect(result.isLeft(), true);
    });
  });
}
