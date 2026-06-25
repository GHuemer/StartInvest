import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:startinvest/features/content/data/repositories/content_repository_impl.dart';
import 'package:startinvest/features/games/data/datasources/market_api_datasource.dart';
import 'package:startinvest/features/games/data/datasources/portfolio_firestore_datasource.dart';
import 'package:startinvest/features/games/data/models/portfolio/trade_model.dart';
import 'package:startinvest/features/games/data/models/portfolio/wallet_model.dart';
import 'package:startinvest/features/games/data/repositories/portfolio_repository_impl.dart';
import 'package:startinvest/features/games/domain/entities/market_asset.dart';
import 'package:startinvest/features/games/domain/entities/position.dart';
import 'package:startinvest/features/games/domain/entities/trade.dart';
import 'package:startinvest/features/home/data/repositories/home_repository_impl.dart';
import 'package:startinvest/features/missions/data/datasources/missions_remote_datasource.dart';
import 'package:startinvest/features/missions/data/repositories/missions_repository_impl.dart';
import 'package:startinvest/features/missions/domain/entities/mission_entity.dart';
import 'package:startinvest/features/news/data/datasources/news_remote_datasource.dart';
import 'package:startinvest/features/news/data/repositories/news_repository_impl.dart';

class MockNewsRemoteDataSource extends Mock implements NewsRemoteDataSource {}

class MockMissionsRemoteDataSource extends Mock
    implements MissionsRemoteDataSource {}

class MockPortfolioFirestoreDataSource extends Mock
    implements PortfolioFirestoreDataSource {}

class MockMarketApiDataSource extends Mock implements MarketApiDataSource {}

void main() {
  setUpAll(() => registerFallbackValue(AssetType.stock));

  group('HomeRepositoryImpl', () {
    test('getDailyChallenge retorna um desafio mock', () async {
      final challenge = await HomeRepositoryImpl().getDailyChallenge();
      expect(challenge.points, 500);
      expect(challenge.title.isNotEmpty, true);
    });
  });

  group('ContentRepositoryImpl', () {
    final repo = ContentRepositoryImpl();
    test('getArticles retorna lista nao vazia', () async {
      final articles = await repo.getArticles();
      expect(articles, isNotEmpty);
      expect(articles.first.id, '1');
    });

    test('getCourses retorna lista nao vazia', () async {
      final courses = await repo.getCourses();
      expect(courses, isNotEmpty);
    });
  });

  group('NewsRepositoryImpl', () {
    late MockNewsRemoteDataSource ds;
    late NewsRepositoryImpl repo;

    setUp(() {
      ds = MockNewsRemoteDataSource();
      repo = NewsRepositoryImpl(ds);
    });

    test('mapeia maps do datasource para NewsEntry', () async {
      when(() => ds.getNews()).thenAnswer((_) async => [
            {
              'id': 'n1',
              'title': 'T',
              'content': 'C',
              'source': 'S',
              'date': 'hoje',
              'tag': 'tag',
              'category': 'tech',
            }
          ]);

      final news = await repo.getNews();
      expect(news.length, 1);
      expect(news.first.id, 'n1');
      expect(news.first.category, 'tech');
    });
  });

  group('MissionsRepositoryImpl', () {
    late MockMissionsRemoteDataSource ds;
    late MissionsRepositoryImpl repo;

    setUp(() {
      ds = MockMissionsRemoteDataSource();
      repo = MissionsRepositoryImpl(remoteDataSource: ds);
    });

    test('getMissions mapeia catalogo do datasource', () async {
      when(() => ds.getMissionsCatalog()).thenAnswer((_) async => [
            {'id': 'm1', 'title': 'M1', 'category': 'learning'},
          ]);

      final missions = await repo.getMissions();
      expect(missions.length, 1);
      expect(missions.first, isA<MissionEntity>());
      expect(missions.first.id, 'm1');
    });

    test('getMissions retorna lista vazia em caso de erro', () async {
      when(() => ds.getMissionsCatalog()).thenThrow(Exception('erro'));
      expect(await repo.getMissions(), isEmpty);
    });

    test('getUserProgress retorna mapa vazio em caso de erro', () async {
      when(() => ds.getUserProgress()).thenThrow(Exception('erro'));
      expect(await repo.getUserProgress(), isEmpty);
    });

    test('getUserProgress delega ao datasource', () async {
      when(() => ds.getUserProgress())
          .thenAnswer((_) async => {'level': 5});
      expect(await repo.getUserProgress(), {'level': 5});
    });
  });

  group('PortfolioRepositoryImpl', () {
    late MockPortfolioFirestoreDataSource firestore;
    late MockMarketApiDataSource market;
    late PortfolioRepositoryImpl repo;

    final wallet = WalletModel(
      id: 'w1',
      userId: 'u1',
      name: 'Carteira',
      startingBalance: 10000,
      availableBalance: 10000,
      createdAt: DateTime(2024),
    );
    final trade = TradeModel(
      id: 't1',
      walletId: 'w1',
      ticker: 'PETR4',
      assetType: AssetType.stock,
      type: TradeType.buy,
      quantity: 10,
      price: 30,
      totalValue: 300,
      timestamp: DateTime(2024),
    );
    final asset = MarketAsset(
      ticker: 'PETR4',
      name: 'Petrobras',
      type: AssetType.stock,
      currentPrice: 30,
      changePercent: 1,
      fetchedAt: DateTime(2024),
    );

    setUp(() {
      firestore = MockPortfolioFirestoreDataSource();
      market = MockMarketApiDataSource();
      repo = PortfolioRepositoryImpl(firestore, market);
    });

    test('getWallets retorna Right com as carteiras', () async {
      when(() => firestore.getWallets()).thenAnswer((_) async => [wallet]);
      final result = await repo.getWallets();
      expect(result.isRight(), true);
      result.fold((_) => fail('esperava Right'), (w) => expect(w.length, 1));
    });

    test('getWallets retorna Left (ServerFailure) em caso de erro', () async {
      when(() => firestore.getWallets()).thenThrow(Exception('boom'));
      final result = await repo.getWallets();
      expect(result.isLeft(), true);
    });

    test('createWallet delega ao firestore', () async {
      when(() => firestore.createWallet(any(), any()))
          .thenAnswer((_) async => wallet);
      final result = await repo.createWallet('Carteira', 10000);
      expect(result.isRight(), true);
    });

    test('buyAsset retorna Right com o trade', () async {
      when(() => firestore.buyAsset(
            walletId: any(named: 'walletId'),
            ticker: any(named: 'ticker'),
            assetType: any(named: 'assetType'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
          )).thenAnswer((_) async => trade);
      final result = await repo.buyAsset(
        walletId: 'w1',
        ticker: 'PETR4',
        assetType: AssetType.stock,
        quantity: 10,
        price: 30,
      );
      expect(result.isRight(), true);
    });

    test('getAssetPrice retorna Left (NetworkFailure) em caso de erro',
        () async {
      when(() => market.getAssetPrice(any(), any()))
          .thenThrow(Exception('rede'));
      final result = await repo.getAssetPrice('PETR4', AssetType.stock);
      expect(result.isLeft(), true);
    });

    test('getAssetPrice retorna Right com o ativo', () async {
      when(() => market.getAssetPrice(any(), any()))
          .thenAnswer((_) async => asset);
      final result = await repo.getAssetPrice('PETR4', AssetType.stock);
      expect(result, Right(asset));
    });

    test('getHistoricalCagr delega ao market', () async {
      when(() => market.getHistoricalCagr(any(), any()))
          .thenAnswer((_) async => 0.12);
      final result = await repo.getHistoricalCagr('PETR4', AssetType.stock);
      expect(result.isRight(), true);
    });

    test('deleteWallet retorna Right(null)', () async {
      when(() => firestore.deleteWallet(any())).thenAnswer((_) async {});
      final result = await repo.deleteWallet('w1');
      expect(result.isRight(), true);
    });

    test('awardXp retorna Left em caso de erro', () async {
      when(() => firestore.awardXp(any())).thenThrow(Exception('x'));
      final result = await repo.awardXp(5);
      expect(result.isLeft(), true);
    });
  });
}
