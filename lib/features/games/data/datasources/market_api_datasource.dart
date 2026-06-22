import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/market_asset.dart';
import '../../domain/entities/position.dart';

abstract class MarketApiDataSource {
  Future<MarketAsset> getAssetPrice(String ticker, AssetType type);
  Future<List<MarketAsset>> getAssetsByType(AssetType type);
  Future<List<MarketAsset>> searchAssets(String query, AssetType type);
}

@LazySingleton(as: MarketApiDataSource)
class MarketApiDataSourceImpl implements MarketApiDataSource {
  final Dio _dio;

  // Cache: ticker -> (asset, fetchedAt)
  final Map<String, (MarketAsset, DateTime)> _cache = {};
  static const Duration _cacheDuration = Duration(seconds: 60);

  // brapi.dev — suporta CORS (*), funciona no Flutter Web e mobile
  // Free tier: até 3 tickers por request para Ações; FIIs exigem token
  static const String _brapiBase = 'https://brapi.dev/api';

  // Para desbloquear FIIs, registre em https://brapi.dev e adicione seu token:
  // ignore: unused_field
  static const String? _brapiToken = null;

  MarketApiDataSourceImpl(this._dio);

  static const List<Map<String, String>> _stocks = [
    {'ticker': 'PETR4', 'name': 'Petrobras PN', 'price': '36.50'},
    {'ticker': 'VALE3', 'name': 'Vale ON', 'price': '58.20'},
    {'ticker': 'ITUB4', 'name': 'Itaú Unibanco PN', 'price': '28.80'},
    {'ticker': 'BBAS3', 'name': 'Banco do Brasil ON', 'price': '25.40'},
    {'ticker': 'ABEV3', 'name': 'Ambev ON', 'price': '11.90'},
    {'ticker': 'WEGE3', 'name': 'WEG ON', 'price': '42.60'},
    {'ticker': 'RENT3', 'name': 'Localiza ON', 'price': '51.30'},
    {'ticker': 'MGLU3', 'name': 'Magazine Luiza ON', 'price': '8.70'},
  ];

  static const List<Map<String, String>> _fiis = [
    {'ticker': 'MXRF11', 'name': 'Maxi Renda FII', 'price': '9.85'},
    {'ticker': 'HGLG11', 'name': 'CSHG Logística FII', 'price': '160.40'},
    {'ticker': 'XPML11', 'name': 'XP Malls FII', 'price': '87.20'},
    {'ticker': 'KNRI11', 'name': 'Kinea Renda Imob. FII', 'price': '152.10'},
    {
      'ticker': 'VISC11',
      'name': 'Vinci Shopping Centers FII',
      'price': '94.60',
    },
  ];

  static const List<Map<String, String>> _fixedIncome = [
    {
      'ticker': 'CDB_CDI_100',
      'name': 'CDB 100% CDI',
      'price': '1000.00',
      'rate': '1.0',
    },
    {
      'ticker': 'CDB_CDI_110',
      'name': 'CDB 110% CDI',
      'price': '1000.00',
      'rate': '1.1',
    },
    {
      'ticker': 'TESOURO_SELIC',
      'name': 'Tesouro Selic 2027',
      'price': '14250.00',
      'rate': '1.0',
    },
    {
      'ticker': 'TESOURO_IPCA',
      'name': 'Tesouro IPCA+ 2029',
      'price': '4100.00',
      'rate': '1.05',
    },
  ];

  // CDI anual aproximado para simulação de Renda Fixa
  static const double _cdiAnnualRate = 0.1375;
  static const double _cdiDailyRate = _cdiAnnualRate / 252;

  // Tamanho máximo do batch sem token no brapi.dev
  static const int _batchSize = 3;

  @override
  Future<MarketAsset> getAssetPrice(String ticker, AssetType type) async {
    if (type == AssetType.fixedIncome) return _fixedIncomeAsset(ticker);
    if (type == AssetType.fii) return _fallbackAsset(ticker, type);

    final cached = _cache[ticker];
    if (cached != null &&
        DateTime.now().difference(cached.$2) < _cacheDuration) {
      return cached.$1;
    }

    try {
      final asset = await _fetchBrapi([ticker], type);
      if (asset.isNotEmpty) {
        _cache[ticker] = (asset.first, DateTime.now());
        return asset.first;
      }
    } catch (e) {
      debugPrint('[MarketAPI] Erro ao buscar $ticker: $e');
    }
    return _fallbackAsset(ticker, type);
  }

  @override
  Future<List<MarketAsset>> getAssetsByType(AssetType type) async {
    if (type == AssetType.fixedIncome) {
      return _fixedIncome.map((e) => _fixedIncomeAsset(e['ticker']!)).toList();
    }

    // FIIs exigem token no brapi.dev — usa fallback com preços de referência
    if (type == AssetType.fii) {
      return _fiis.map((e) => _fallbackAsset(e['ticker']!, type)).toList();
    }

    // Ações: brapi.dev suporta até 3 por request sem token
    final catalog = _stocks;
    final results = <MarketAsset>[];

    for (var i = 0; i < catalog.length; i += _batchSize) {
      final batch = catalog.skip(i).take(_batchSize).toList();
      final tickers = batch.map((e) => e['ticker']!).toList();

      // Verifica cache primeiro
      final uncached = tickers.where((t) {
        final c = _cache[t];
        return c == null || DateTime.now().difference(c.$2) >= _cacheDuration;
      }).toList();

      // Adiciona do cache os que já estão frescos
      for (final t in tickers) {
        final c = _cache[t];
        if (c != null && DateTime.now().difference(c.$2) < _cacheDuration) {
          results.add(c.$1);
        }
      }

      if (uncached.isEmpty) continue;

      try {
        final fetched = await _fetchBrapi(uncached, type);
        for (final asset in fetched) {
          _cache[asset.ticker] = (asset, DateTime.now());
          results.add(asset);
        }
        // Fallback para os que não vieram na resposta
        final fetchedTickers = fetched.map((a) => a.ticker).toSet();
        for (final t in uncached.where((t) => !fetchedTickers.contains(t))) {
          results.add(_fallbackAsset(t, type));
        }
      } catch (e) {
        debugPrint('[MarketAPI] Erro no batch $tickers: $e');
        for (final t in uncached) {
          results.add(_fallbackAsset(t, type));
        }
      }
    }

    return results;
  }

  @override
  Future<List<MarketAsset>> searchAssets(String query, AssetType type) async {
    final all = await getAssetsByType(type);
    if (query.isEmpty) return all;
    final q = query.toUpperCase();
    return all
        .where((a) => a.ticker.contains(q) || a.name.toUpperCase().contains(q))
        .toList();
  }

  Future<List<MarketAsset>> _fetchBrapi(
    List<String> tickers,
    AssetType type,
  ) async {
    final tickerStr = tickers.join(',');
    final queryParams = <String, dynamic>{};
    if (_brapiToken != null) queryParams['token'] = _brapiToken;

    final response = await _dio.get(
      '$_brapiBase/quote/$tickerStr',
      queryParameters: queryParams,
    );
    final raw = response.data;

    if (raw['error'] == true) {
      throw Exception(raw['message'] ?? 'brapi.dev error');
    }

    final list = raw['results'] as List? ?? [];
    return list.map((data) {
      final ticker = data['symbol'] as String;
      final catalog = type == AssetType.stock ? _stocks : _fiis;
      final catalogName = catalog
          .where((e) => e['ticker'] == ticker)
          .map((e) => e['name']!)
          .firstOrNull;
      final price = (data['regularMarketPrice'] as num).toDouble();
      final changePct =
          (data['regularMarketChangePercent'] as num?)?.toDouble() ?? 0.0;
      return MarketAsset(
        ticker: ticker,
        name: catalogName ?? (data['shortName'] as String? ?? ticker),
        type: type,
        currentPrice: price,
        changePercent: changePct,
        fetchedAt: DateTime.now(),
      );
    }).toList();
  }

  MarketAsset _fixedIncomeAsset(String ticker) {
    final info = _fixedIncome.firstWhere(
      (e) => e['ticker'] == ticker,
      orElse: () => {
        'ticker': ticker,
        'name': ticker,
        'price': '1000',
        'rate': '1.0',
      },
    );
    final basePrice = double.tryParse(info['price']!) ?? 1000.0;
    final rateMultiplier = double.tryParse(info['rate']!) ?? 1.0;
    final effectiveDailyRate = _cdiDailyRate * rateMultiplier;
    final currentPrice = basePrice * (1 + effectiveDailyRate);
    // changePercent mostra rendimento anual estimado (mais informativo para RF)
    final annualYieldPct = _cdiAnnualRate * rateMultiplier * 100;
    return MarketAsset(
      ticker: ticker,
      name: info['name']!,
      type: AssetType.fixedIncome,
      currentPrice: currentPrice,
      changePercent: annualYieldPct,
      fetchedAt: DateTime.now(),
    );
  }

  MarketAsset _fallbackAsset(String ticker, AssetType type) {
    final catalog = type == AssetType.stock ? _stocks : _fiis;
    final info = catalog.firstWhere(
      (e) => e['ticker'] == ticker,
      orElse: () => {'ticker': ticker, 'name': ticker, 'price': '0'},
    );
    return MarketAsset(
      ticker: ticker,
      name: info['name']!,
      type: type,
      currentPrice: double.tryParse(info['price'] ?? '0') ?? 0.0,
      changePercent: 0.0,
      isOffline: true,
      fetchedAt: DateTime.now(),
    );
  }
}
