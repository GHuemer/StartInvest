import 'package:flutter_test/flutter_test.dart';

import 'package:startinvest/features/games/domain/entities/game_result.dart';
import 'package:startinvest/features/games/domain/entities/game_session.dart';
import 'package:startinvest/features/games/domain/entities/market_asset.dart';
import 'package:startinvest/features/games/domain/entities/market_question.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/quiz_question.dart';
import 'package:startinvest/features/games/domain/entities/simulation_result.dart';
import 'package:startinvest/features/games/domain/entities/trade.dart';
import 'package:startinvest/features/games/domain/entities/wallet.dart';

void main() {
  group('AssetType / AssetTypeLabel', () {
    test('value mapeia para string correta', () {
      expect(AssetType.stock.value, 'stock');
      expect(AssetType.fii.value, 'fii');
      expect(AssetType.fixedIncome.value, 'fixedIncome');
    });

    test('label nao e vazio para todos os tipos', () {
      for (final t in AssetType.values) {
        expect(t.label.isNotEmpty, true);
      }
    });

    test('fromString reconhece valores e cai no padrao stock', () {
      expect(AssetTypeLabel.fromString('fii'), AssetType.fii);
      expect(AssetTypeLabel.fromString('fixedIncome'), AssetType.fixedIncome);
      expect(AssetTypeLabel.fromString('stock'), AssetType.stock);
      expect(AssetTypeLabel.fromString('desconhecido'), AssetType.stock);
    });
  });

  group('Position', () {
    final position = Position(
      ticker: 'PETR4',
      walletId: 'w1',
      assetType: AssetType.stock,
      quantity: 10,
      avgBuyPrice: 20,
      currentPrice: 25,
      purchaseDate: DateTime(2024),
    );

    test('calcula custo, valor e lucro', () {
      expect(position.totalCost, 200);
      expect(position.currentValue, 250);
      expect(position.profitLoss, 50);
      expect(position.profitLossPct, 25);
    });

    test('profitLossPct e zero quando custo e zero', () {
      final empty = position.copyWith(quantity: 0);
      expect(empty.profitLossPct, 0);
    });

    test('copyWith preserva campos imutaveis', () {
      final updated = position.copyWith(currentPrice: 30);
      expect(updated.currentPrice, 30);
      expect(updated.ticker, 'PETR4');
      expect(updated.walletId, 'w1');
    });
  });

  group('Wallet', () {
    final wallet = Wallet(
      id: 'w1',
      userId: 'u1',
      name: 'Carteira',
      startingBalance: 10000,
      availableBalance: 4000,
      createdAt: DateTime(2024),
    );

    test('totalInvested = saldo inicial - disponivel', () {
      expect(wallet.totalInvested, 6000);
    });

    test('copyWith altera nome e saldo', () {
      final updated = wallet.copyWith(name: 'Nova', availableBalance: 5000);
      expect(updated.name, 'Nova');
      expect(updated.availableBalance, 5000);
      expect(updated.startingBalance, 10000);
    });
  });

  group('MarketAsset', () {
    test('isStale falso quando recem buscado', () {
      final asset = MarketAsset(
        ticker: 'PETR4',
        name: 'Petrobras',
        type: AssetType.stock,
        currentPrice: 30,
        changePercent: 1.5,
        fetchedAt: DateTime.now(),
      );
      expect(asset.isStale, false);
    });

    test('isStale verdadeiro quando passou mais de 60s', () {
      final asset = MarketAsset(
        ticker: 'PETR4',
        name: 'Petrobras',
        type: AssetType.stock,
        currentPrice: 30,
        changePercent: 1.5,
        fetchedAt: DateTime.now().subtract(const Duration(seconds: 120)),
      );
      expect(asset.isStale, true);
    });

    test('copyWith atualiza preco e fetchedAt', () {
      final asset = MarketAsset(
        ticker: 'PETR4',
        name: 'Petrobras',
        type: AssetType.stock,
        currentPrice: 30,
        changePercent: 1.5,
        fetchedAt: DateTime(2020),
      );
      final updated = asset.copyWith(currentPrice: 35);
      expect(updated.currentPrice, 35);
      expect(updated.fetchedAt.isAfter(DateTime(2020)), true);
    });
  });

  group('GameSession', () {
    MarketQuestion q(bool answer) => MarketQuestion(
          id: 'q',
          story: 's',
          company: 'c',
          correctAnswer: answer,
          difficulty: 'easy',
        );

    test('streak conta acertos consecutivos ate o primeiro erro', () {
      final session = GameSession(
        id: 's1',
        difficulty: 'easy',
        questions: [q(true), q(true), q(false), q(true)],
        answers: const [true, true, true, true],
        startedAt: DateTime(2024),
      );
      // acerta, acerta, erra -> streak 2
      expect(session.streak, 2);
    });

    test('maxStreakBonus depende da dificuldade', () {
      GameSession base(String d) => GameSession(
            id: 's',
            difficulty: d,
            questions: const [],
            startedAt: DateTime(2024),
          );
      expect(base('easy').maxStreakBonus, 30);
      expect(base('medium').maxStreakBonus, 50);
      expect(base('hard').maxStreakBonus, 70);
      expect(base('outro').maxStreakBonus, 30);
    });

    test('calculatePointsForQuestion respeita multiplicador e teto', () {
      final easy = GameSession(
        id: 's',
        difficulty: 'easy',
        questions: const [],
        startedAt: DateTime(2024),
      );
      // (0+1)*5 = 5
      expect(easy.calculatePointsForQuestion(0), 5);
      // questao 10 -> (11)*5 = 55, mas teto easy = 30
      expect(easy.calculatePointsForQuestion(10), 30);
    });

    test('copyWith atualiza pontuacao', () {
      final session = GameSession(
        id: 's',
        difficulty: 'easy',
        questions: const [],
        startedAt: DateTime(2024),
      );
      final updated = session.copyWith(totalPoints: 99, isComplete: true);
      expect(updated.totalPoints, 99);
      expect(updated.isComplete, true);
      expect(updated.id, 's');
    });
  });

  group('GameResult', () {
    test('toMap serializa todos os campos', () {
      final result = GameResult(
        sessionId: 's1',
        difficulty: 'hard',
        totalPoints: 100,
        correctAnswers: 8,
        totalQuestions: 10,
        accuracy: 0.8,
        completedAt: DateTime(2024, 5, 1),
        bestStreak: 5,
      );
      final map = result.toMap();
      expect(map['sessionId'], 's1');
      expect(map['difficulty'], 'hard');
      expect(map['totalPoints'], 100);
      expect(map['accuracy'], 0.8);
      expect(map['completedAt'], DateTime(2024, 5, 1).toIso8601String());
      expect(map['bestStreak'], 5);
    });
  });

  group('Trade entity', () {
    test('igualdade por valor', () {
      final t1 = Trade(
        id: 't1',
        walletId: 'w1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        type: TradeType.buy,
        quantity: 10,
        price: 20,
        totalValue: 200,
        timestamp: DateTime(2024),
      );
      final t2 = Trade(
        id: 't1',
        walletId: 'w1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        type: TradeType.buy,
        quantity: 10,
        price: 20,
        totalValue: 200,
        timestamp: DateTime(2024),
      );
      expect(t1, t2);
    });
  });

  group('Projection entities', () {
    test('AssetProjection calcula ganho e percentual', () {
      const proj = AssetProjection(
        ticker: 'PETR4',
        name: 'Petrobras',
        assetType: AssetType.stock,
        investedAmount: 1000,
        annualRate: 0.1,
        dataPoints: [1000, 1100, 1200],
      );
      expect(proj.projectedValue, 1200);
      expect(proj.absoluteGain, 200);
      expect(proj.gainPercent, closeTo(20, 0.0001));
    });

    test('AssetProjection sem pontos usa investedAmount', () {
      const proj = AssetProjection(
        ticker: 'X',
        name: 'X',
        assetType: AssetType.fii,
        investedAmount: 500,
        annualRate: 0.1,
        dataPoints: [],
      );
      expect(proj.projectedValue, 500);
      expect(proj.gainPercent, 0);
    });

    test('ProjectionAssetInput copyWith altera amount', () {
      const input = ProjectionAssetInput(
        ticker: 'PETR4',
        name: 'Petrobras',
        assetType: AssetType.stock,
        amount: 100,
      );
      expect(input.copyWith(amount: 250).amount, 250);
    });

    test('SimulationResult consolida totais', () {
      const sim = SimulationResult(
        assets: [
          AssetProjection(
            ticker: 'A',
            name: 'A',
            assetType: AssetType.stock,
            investedAmount: 1000,
            annualRate: 0.1,
            dataPoints: [1000, 1200],
          ),
          AssetProjection(
            ticker: 'B',
            name: 'B',
            assetType: AssetType.fii,
            investedAmount: 1000,
            annualRate: 0.1,
            dataPoints: [1000, 1100],
          ),
        ],
        periodMonths: 24,
        periodLabel: '2 anos',
        consolidatedPoints: [2000, 2300],
      );
      expect(sim.totalInvested, 2000);
      expect(sim.totalProjected, 2300);
      expect(sim.totalGainPercent, closeTo(15, 0.0001));
      expect(sim.isYearly, true);
    });

    test('SimulationResult sem pontos consolidados usa totalInvested', () {
      const sim = SimulationResult(
        assets: [],
        periodMonths: 6,
        periodLabel: '6 meses',
        consolidatedPoints: [],
      );
      expect(sim.totalProjected, 0);
      expect(sim.totalGainPercent, 0);
      expect(sim.isYearly, false);
    });
  });

  group('Quiz entities', () {
    test('QuizQuestion mantem opcoes e indice correto', () {
      const question = QuizQuestion(
        question: 'Qual?',
        options: ['A', 'B', 'C'],
        correctAnswerIndex: 1,
      );
      expect(question.options.length, 3);
      expect(question.correctAnswerIndex, 1);
    });

    test('Quiz armazena dificuldade e perguntas', () {
      const quiz = Quiz(
        id: 'q1',
        title: 'Teste',
        description: 'desc',
        difficulty: QuizDifficulty.moderate,
        questions: [],
        iconPath: 'icon.png',
      );
      expect(quiz.difficulty, QuizDifficulty.moderate);
      expect(quiz.questions, isEmpty);
    });
  });
}
