import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/features/auth/data/models/user_model.dart';
import 'package:startinvest/features/content/data/models/article_model.dart';
import 'package:startinvest/features/content/data/models/course_model.dart';
import 'package:startinvest/features/games/data/models/market_question_model.dart';
import 'package:startinvest/features/games/data/models/portfolio/position_model.dart';
import 'package:startinvest/features/games/data/models/portfolio/trade_model.dart';
import 'package:startinvest/features/games/data/models/portfolio/wallet_model.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/trade.dart';
import 'package:startinvest/features/home/data/models/challenge_model.dart';
import 'package:startinvest/features/missions/data/models/mission_model.dart';
import 'package:startinvest/features/missions/domain/entities/mission_entity.dart';
import 'package:startinvest/features/news/data/models/news_model.dart';
import 'package:startinvest/features/profile/data/models/user_profile_model.dart';

class _FakeFirebaseUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  _FakeFirebaseUser(this.uid, this.displayName, this.email, this.photoURL);
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('UserModel', () {
    test('fromMap converte mapa do Firestore', () {
      final model = UserModel.fromMap({
        'username': 'joao',
        'name': 'Joao',
        'email': 'joao@test.com',
        'xp': 50,
        'level': 2,
        'league': 'prata',
        'birthDate': Timestamp.fromDate(DateTime(2000, 5, 10)),
      }, 'u1');

      expect(model.id, 'u1');
      expect(model.username, 'joao');
      expect(model.xp, 50);
      expect(model.level, 2);
      expect(model.league, 'prata');
      expect(model.birthDate, DateTime(2000, 5, 10));
      expect(model.isNewUser, false);
    });

    test('fromMap aplica defaults para campos ausentes', () {
      final model = UserModel.fromMap({}, 'u2');
      expect(model.username, '');
      expect(model.xp, 0);
      expect(model.level, 1);
      expect(model.league, 'bronze');
      expect(model.birthDate, isNull);
    });

    test('toMap serializa os campos', () {
      final model = UserModel(
        id: 'u1',
        username: 'joao',
        name: 'Joao',
        email: 'joao@test.com',
        birthDate: DateTime(2000),
      );
      final map = model.toMap();
      expect(map['username'], 'joao');
      expect(map['email'], 'joao@test.com');
      expect(map['birthDate'], isA<Timestamp>());
    });

    test('fromFirebaseUser mapeia usuario do Auth', () {
      final model = UserModel.fromFirebaseUser(
        _FakeFirebaseUser('uid1', 'Maria', 'maria@test.com', 'http://img'),
        username: 'maria',
        isNewUser: true,
      );
      expect(model.id, 'uid1');
      expect(model.name, 'Maria');
      expect(model.email, 'maria@test.com');
      expect(model.photoUrl, 'http://img');
      expect(model.username, 'maria');
      expect(model.isNewUser, true);
    });
  });

  group('ArticleModel', () {
    test('fromMap e toMap sao consistentes', () {
      final model = ArticleModel.fromMap({
        'title': 'T',
        'content': 'C',
        'author': 'A',
        'readingTime': '5 min',
        'publishedAt': '2024-01-01T00:00:00.000',
      }, 'a1');
      expect(model.id, 'a1');
      expect(model.publishedAt, DateTime.parse('2024-01-01T00:00:00.000'));

      final map = model.toMap();
      expect(map['title'], 'T');
      expect(map['publishedAt'], '2024-01-01T00:00:00.000');
    });

    test('fromMap usa now() quando publishedAt ausente', () {
      final model = ArticleModel.fromMap({'title': 'X'}, 'a2');
      expect(model.title, 'X');
      expect(model.author, '');
    });
  });

  group('CourseModel', () {
    test('fromMap e toMap', () {
      final model = CourseModel.fromMap({
        'title': 'Curso',
        'videoUrl': 'http://v',
        'thumbnailUrl': 'http://t',
      }, 'c1');
      expect(model.id, 'c1');
      expect(model.videoUrl, 'http://v');
      expect(model.toMap()['thumbnailUrl'], 'http://t');
    });
  });

  group('MarketQuestionModel', () {
    test('fromMap e toMap round-trip', () {
      final map = {
        'id': 'q1',
        'story': 's',
        'company': 'c',
        'correctAnswer': true,
        'difficulty': 'easy',
        'explanation': 'exp',
      };
      final model = MarketQuestionModel.fromMap(map);
      expect(model.id, 'q1');
      expect(model.correctAnswer, true);
      expect(model.toMap()['difficulty'], 'easy');
    });
  });

  group('PositionModel', () {
    test('fromFirestore usa avgBuyPrice como currentPrice', () {
      final model = PositionModel.fromFirestore('PETR4', {
        'assetType': 'stock',
        'quantity': 10,
        'avgBuyPrice': 25.0,
        'createdAt': Timestamp.fromDate(DateTime(2024)),
      }, 'w1');
      expect(model.ticker, 'PETR4');
      expect(model.walletId, 'w1');
      expect(model.quantity, 10);
      expect(model.avgBuyPrice, 25.0);
      expect(model.currentPrice, 25.0);
      expect(model.assetType, AssetType.stock);
    });

    test('fromFirestore aplica defaults', () {
      final model = PositionModel.fromFirestore('XPTO', {}, 'w1');
      expect(model.quantity, 0.0);
      expect(model.assetType, AssetType.stock);
    });

    test('toFirestore serializa o tipo como value', () {
      final model = PositionModel.fromFirestore('HGLG11', {
        'assetType': 'fii',
        'quantity': 5,
        'avgBuyPrice': 100.0,
      }, 'w1');
      final map = model.toFirestore();
      expect(map['assetType'], 'fii');
      expect(map['quantity'], 5);
    });
  });

  group('TradeModel', () {
    test('fromFirestore interpreta tipo sell', () {
      final model = TradeModel.fromFirestore('t1', {
        'walletId': 'w1',
        'ticker': 'PETR4',
        'assetType': 'stock',
        'type': 'sell',
        'quantity': 10,
        'price': 30.0,
        'totalValue': 300.0,
        'timestamp': Timestamp.fromDate(DateTime(2024)),
        'xpEarned': 15,
      });
      expect(model.type, TradeType.sell);
      expect(model.xpEarned, 15);
      expect(model.totalValue, 300.0);
    });

    test('fromFirestore assume buy por padrao', () {
      final model = TradeModel.fromFirestore('t2', {'ticker': 'VALE3'});
      expect(model.type, TradeType.buy);
      expect(model.ticker, 'VALE3');
      expect(model.quantity, 0.0);
    });
  });

  group('WalletModel', () {
    test('fromFirestore e toFirestore', () {
      final model = WalletModel.fromFirestore('w1', {
        'userId': 'u1',
        'name': 'Carteira',
        'startingBalance': 10000,
        'availableBalance': 8000,
        'createdAt': Timestamp.fromDate(DateTime(2024)),
        'lastPortfolioValue': 9000,
      });
      expect(model.userId, 'u1');
      expect(model.startingBalance, 10000);
      expect(model.lastPortfolioValue, 9000);

      final map = model.toFirestore();
      expect(map['name'], 'Carteira');
      expect(map['createdAt'], isA<Timestamp>());
    });
  });

  group('ChallengeModel', () {
    test('fromMap e toMap', () {
      final model = ChallengeModel.fromMap({
        'tag': 'tag',
        'title': 'T',
        'description': 'D',
        'points': 100,
        'iconType': 'rocket',
      }, 'ch1');
      expect(model.id, 'ch1');
      expect(model.points, 100);
      expect(model.toMap()['iconType'], 'rocket');
    });
  });

  group('MissionModel', () {
    test('fromFirestore mapeia categoria e icone conhecidos', () {
      final model = MissionModel.fromFirestore({
        'title': 'Missao',
        'description': 'desc',
        'icon': 'book',
        'category': 'practice',
        'requiredLevel': 2,
        'rewardPoints': 80,
      }, 'm1');
      expect(model.id, 'm1');
      expect(model.category, MissionCategory.practice);
      expect(model.icon, Icons.menu_book);
      expect(model.rewardPoints, 80);
    });

    test('fromFirestore cai em defaults para valores desconhecidos', () {
      final model = MissionModel.fromFirestore({
        'title': 'M',
        'icon': 'desconhecido',
        'category': 'qualquer',
      }, 'm2');
      expect(model.category, MissionCategory.learning);
      expect(model.icon, Icons.emoji_events);
      expect(model.rewardPoints, 50);
    });
  });

  group('NewsModel', () {
    test('fromJson e toJson round-trip', () {
      final json = {
        'id': 'n1',
        'title': 'T',
        'content': 'C',
        'source': 'S',
        'date': 'hoje',
        'tag': 'tag',
        'category': 'cat',
      };
      final model = NewsModel.fromJson(json);
      expect(model.id, 'n1');
      expect(model.toJson(), json);
    });
  });

  group('UserProfileModel', () {
    test('fromFirestore deriva memberSince do createdAt', () {
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('u1');
      when(() => doc.data()).thenReturn({
        'username': 'joao',
        'name': 'Joao',
        'email': 'joao@test.com',
        'xp': 100,
        'level': 2,
        'league': 'prata',
        'balance': 1500.0,
        'createdAt': Timestamp.fromDate(DateTime(2024, 6, 15)),
        'completedMissionsIds': ['m1', 'm2'],
        'friendIds': ['f1'],
      });

      final model = UserProfileModel.fromFirestore(doc);
      expect(model.id, 'u1');
      expect(model.username, 'joao');
      expect(model.xp, 100);
      expect(model.balance, 1500.0);
      expect(model.memberSince, 'junho de 2024');
      expect(model.completedMissionsIds, ['m1', 'm2']);
      expect(model.friendIds, ['f1']);
    });

    test('fromFirestore aplica defaults quando data e nula', () {
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('u2');
      when(() => doc.data()).thenReturn(null);

      final model = UserProfileModel.fromFirestore(doc);
      expect(model.xp, 0);
      expect(model.level, 1);
      expect(model.league, 'bronze');
      expect(model.completedMissionsIds, isEmpty);
    });

    test('toFirestore serializa todos os campos', () {
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('u1');
      when(() => doc.data()).thenReturn({'username': 'joao', 'xp': 10});
      final model = UserProfileModel.fromFirestore(doc);

      final map = model.toFirestore();
      expect(map['username'], 'joao');
      expect(map['xp'], 10);
      expect(map.containsKey('friendIds'), true);
    });
  });
}
