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

  // Yahoo Finance — sem token, tickers brasileiros usam sufixo .SA
  static const String _yahooBase =
      'https://query2.finance.yahoo.com/v8/finance/chart';

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

  @override
  Future<MarketAsset> getAssetPrice(String ticker, AssetType type) async {
    if (type == AssetType.fixedIncome) {
      return _fixedIncomeAsset(ticker);
    }

    final cached = _cache[ticker];
    if (cached != null &&
        DateTime.now().difference(cached.$2) < _cacheDuration) {
      return cached.$1;
    }

    try {
      final asset = await _fetchFromYahoo(ticker, type);
      _cache[ticker] = (asset, DateTime.now());
      return asset;
    } catch (e) {
      debugPrint('[MarketAPI] Erro ao buscar $ticker: $e');
      return _fallbackAsset(ticker, type);
    }
  }

  @override
  Future<List<MarketAsset>> getAssetsByType(AssetType type) async {
    if (type == AssetType.fixedIncome) {
      return _fixedIncome.map((e) => _fixedIncomeAsset(e['ticker']!)).toList();
    }

    final catalog = type == AssetType.stock ? _stocks : _fiis;

    // Busca em paralelo — Yahoo Finance suporta sem limite de token
    final results = await Future.wait(
      catalog.map((info) async {
        final ticker = info['ticker']!;
        try {
          final cached = _cache[ticker];
          if (cached != null &&
              DateTime.now().difference(cached.$2) < _cacheDuration) {
            return cached.$1;
          }
          final asset = await _fetchFromYahoo(ticker, type);
          _cache[ticker] = (asset, DateTime.now());
          return asset;
        } catch (e) {
          debugPrint('[MarketAPI] Erro ao buscar $ticker: $e');
          return _fallbackAsset(ticker, type);
        }
      }),
    );

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

  Future<MarketAsset> _fetchFromYahoo(String ticker, AssetType type) async {
    final yahooTicker = '${ticker}.SA';
    final response = await _dio.get(
      '$_yahooBase/$yahooTicker',
      queryParameters: {'interval': '1d', 'range': '1d'},
    );

    final result =
        (response.data['chart']['result'] as List?)?.first
            as Map<String, dynamic>?;
    if (result == null) throw Exception('Sem dados para $ticker');

    final meta = result['meta'] as Map<String, dynamic>;
    final price = (meta['regularMarketPrice'] as num).toDouble();
    final prevClose = (meta['previousClose'] as num?)?.toDouble() ?? price;
    final changePct = prevClose > 0
        ? ((price - prevClose) / prevClose) * 100
        : 0.0;

    final catalog = type == AssetType.stock ? _stocks : _fiis;
    final catalogName = catalog
        .where((e) => e['ticker'] == ticker)
        .map((e) => e['name']!)
        .firstOrNull;

    return MarketAsset(
      ticker: ticker,
      name: catalogName ?? (meta['shortName'] as String? ?? ticker),
      type: type,
      currentPrice: price,
      changePercent: changePct,
      fetchedAt: DateTime.now(),
    );
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
