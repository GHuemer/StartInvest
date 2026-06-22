import 'package:flutter_test/flutter_test.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/usecases/portfolio/calculate_portfolio_xp_usecase.dart';

void main() {
  late CalculatePortfolioXpUseCase useCase;

  setUp(() {
    useCase = CalculatePortfolioXpUseCase();
  });

  group('CalculatePortfolioXpUseCase - Renda Fixa (conservador)', () {
    test('deve retornar 0 quando lucro/prejuízo for negativo', () {
      expect(useCase(assetType: AssetType.fixedIncome, profitLossPct: -1), 0);
    });

    test('deve retornar 5 quando lucro estiver entre 0% e 2%', () {
      expect(useCase(assetType: AssetType.fixedIncome, profitLossPct: 0), 5);
      expect(useCase(assetType: AssetType.fixedIncome, profitLossPct: 1.9), 5);
    });

    test('deve retornar 10 quando lucro estiver entre 2% e 5%', () {
      expect(useCase(assetType: AssetType.fixedIncome, profitLossPct: 2), 10);
      expect(useCase(assetType: AssetType.fixedIncome, profitLossPct: 4.9), 10);
    });

    test('deve retornar 20 quando lucro for 5% ou mais', () {
      expect(useCase(assetType: AssetType.fixedIncome, profitLossPct: 5), 20);
      expect(useCase(assetType: AssetType.fixedIncome, profitLossPct: 100), 20);
    });
  });

  group('CalculatePortfolioXpUseCase - FII (moderado)', () {
    test('deve retornar -10 quando prejuízo for menor que -5%', () {
      expect(useCase(assetType: AssetType.fii, profitLossPct: -6), -10);
    });

    test('deve retornar 0 quando prejuízo estiver entre -5% e 0%', () {
      expect(useCase(assetType: AssetType.fii, profitLossPct: -5), 0);
      expect(useCase(assetType: AssetType.fii, profitLossPct: -0.1), 0);
    });

    test('deve retornar 25 quando lucro estiver entre 0% e 5%', () {
      expect(useCase(assetType: AssetType.fii, profitLossPct: 0), 25);
      expect(useCase(assetType: AssetType.fii, profitLossPct: 4.9), 25);
    });

    test('deve retornar 40 quando lucro estiver entre 5% e 10%', () {
      expect(useCase(assetType: AssetType.fii, profitLossPct: 5), 40);
      expect(useCase(assetType: AssetType.fii, profitLossPct: 9.9), 40);
    });

    test('deve retornar 60 quando lucro for 10% ou mais', () {
      expect(useCase(assetType: AssetType.fii, profitLossPct: 10), 60);
      expect(useCase(assetType: AssetType.fii, profitLossPct: 50), 60);
    });
  });

  group('CalculatePortfolioXpUseCase - Ação (agressivo)', () {
    test('deve retornar -30 quando prejuízo for menor que -15%', () {
      expect(useCase(assetType: AssetType.stock, profitLossPct: -16), -30);
    });

    test('deve retornar -10 quando prejuízo estiver entre -15% e -5%', () {
      expect(useCase(assetType: AssetType.stock, profitLossPct: -15), -10);
      expect(useCase(assetType: AssetType.stock, profitLossPct: -5.1), -10);
    });

    test('deve retornar 0 quando prejuízo estiver entre -5% e 0%', () {
      expect(useCase(assetType: AssetType.stock, profitLossPct: -5), 0);
      expect(useCase(assetType: AssetType.stock, profitLossPct: -0.1), 0);
    });

    test('deve retornar 50 quando lucro estiver entre 0% e 10%', () {
      expect(useCase(assetType: AssetType.stock, profitLossPct: 0), 50);
      expect(useCase(assetType: AssetType.stock, profitLossPct: 9.9), 50);
    });

    test('deve retornar 75 quando lucro estiver entre 10% e 25%', () {
      expect(useCase(assetType: AssetType.stock, profitLossPct: 10), 75);
      expect(useCase(assetType: AssetType.stock, profitLossPct: 24.9), 75);
    });

    test('deve retornar 120 quando lucro for 25% ou mais', () {
      expect(useCase(assetType: AssetType.stock, profitLossPct: 25), 120);
      expect(useCase(assetType: AssetType.stock, profitLossPct: 200), 120);
    });
  });
}
