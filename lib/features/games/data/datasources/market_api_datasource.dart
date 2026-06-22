import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/market_asset.dart';
import '../../domain/entities/position.dart';

abstract class MarketApiDataSource {
  Future<MarketAsset> getAssetPrice(String ticker, AssetType type);
  Future<List<MarketAsset>> getAssetsByType(AssetType type);
  Future<List<MarketAsset>> searchAssets(String query, AssetType type);
  Future<double> getHistoricalCagr(String ticker, AssetType type);
}

@LazySingleton(as: MarketApiDataSource)
class MarketApiDataSourceImpl implements MarketApiDataSource {
  final Dio _dio;

  // Cache: ticker -> (asset, fetchedAt)
  final Map<String, (MarketAsset, DateTime)> _cache = {};
  static const Duration _cacheDuration = Duration(seconds: 60);

  // brapi.dev — suporta CORS (*), funciona no Flutter Web e mobile
  static const String _brapiBase = 'https://brapi.dev/api';

  // Token injetado via --dart-define=BRAPI_TOKEN=... em tempo de build.
  // Sem token: máx 3 ações/req, FIIs indisponíveis.
  // Com token (brapi.dev/login): até 20 tickers/req e FIIs desbloqueados.
  static const String _brapiToken = String.fromEnvironment(
    'BRAPI_TOKEN',
    defaultValue: '',
  );

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

  bool get _hasToken => _brapiToken.isNotEmpty;

  // Com token free: 1 ticker/req mas desbloqueia FIIs
  // Sem token: até 3 tickers/req, FIIs indisponíveis
  // Usamos sempre 1 ticker/req quando há token (funciona em qualquer plano)
  int get _batchSize => _hasToken ? 1 : 3;

  @override
  Future<MarketAsset> getAssetPrice(String ticker, AssetType type) async {
    if (type == AssetType.fixedIncome) return _fixedIncomeAsset(ticker);
    if (type == AssetType.fii && !_hasToken)
      return _fallbackAsset(ticker, type);

    final cached = _cache[ticker];
    if (cached != null &&
        DateTime.now().difference(cached.$2) < _cacheDuration) {
      return cached.$1;
    }

    return _fetchWithRetry(ticker, type);
  }

  @override
  Future<List<MarketAsset>> getAssetsByType(AssetType type) async {
    if (type == AssetType.fixedIncome) {
      return _fixedIncome.map((e) => _fixedIncomeAsset(e['ticker']!)).toList();
    }

    // FIIs sem token: fallback imediato (brapi.dev exige token para FIIs)
    if (type == AssetType.fii && !_hasToken) {
      return _fiis.map((e) => _fallbackAsset(e['ticker']!, type)).toList();
    }

    // Ações e FIIs: busca em paralelo (cada ticker individualmente)
    final catalog = type == AssetType.stock ? _stocks : _fiis;

    final results = await Future.wait(
      catalog.map((info) async {
        final ticker = info['ticker']!;
        // Usa cache se ainda fresco
        final cached = _cache[ticker];
        if (cached != null &&
            DateTime.now().difference(cached.$2) < _cacheDuration) {
          return cached.$1;
        }
        return _fetchWithRetry(ticker, type);
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

  Future<MarketAsset> _fetchWithRetry(
    String ticker,
    AssetType type, {
    int attempts = 2,
  }) async {
    for (var i = 0; i < attempts; i++) {
      try {
        final fetched = await _fetchBrapi([ticker], type);
        if (fetched.isNotEmpty) {
          _cache[ticker] = (fetched.first, DateTime.now());
          return fetched.first;
        }
      } catch (e) {
        final isLastAttempt = i == attempts - 1;
        if (isLastAttempt) {
          debugPrint(
            '[MarketAPI] Erro ao buscar $ticker após $attempts tentativas: $e',
          );
        } else {
          debugPrint('[MarketAPI] Timeout em $ticker, tentando novamente...');
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    return _fallbackAsset(ticker, type);
  }

  Future<List<MarketAsset>> _fetchBrapi(
    List<String> tickers,
    AssetType type,
  ) async {
    final tickerStr = tickers.join(',');
    final queryParams = <String, dynamic>{};
    if (_hasToken) queryParams['token'] = _brapiToken;

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

  @override
  Future<double> getHistoricalCagr(String ticker, AssetType type) async {
    if (type == AssetType.fixedIncome) {
      final info = _fixedIncome.firstWhere(
        (e) => e['ticker'] == ticker,
        orElse: () => {'rate': '1.0'},
      );
      final rateMultiplier = double.tryParse(info['rate']!) ?? 1.0;
      return _cdiAnnualRate * rateMultiplier;
    }

    try {
      final queryParams = <String, dynamic>{
        'range': 'max',
        'interval': '1mo',
        'fundamental': 'false',
        'dividends': 'false',
      };
      if (_hasToken) queryParams['token'] = _brapiToken;

      final response = await _dio.get(
        '$_brapiBase/quote/$ticker',
        queryParameters: queryParams,
      );
      final results = response.data['results'] as List? ?? [];
      if (results.isEmpty) throw Exception('Sem dados');

      final historicalData =
          results.first['historicalDataPrice'] as List? ?? [];
      if (historicalData.length < 24) throw Exception('Histórico insuficiente');

      final firstClose =
          (historicalData.first['close'] as num?)?.toDouble() ?? 0;
      final lastClose = (historicalData.last['close'] as num?)?.toDouble() ?? 0;
      final firstDateSec = (historicalData.first['date'] as num?)?.toInt() ?? 0;
      final lastDateSec = (historicalData.last['date'] as num?)?.toInt() ?? 0;

      if (firstClose <= 0 || lastClose <= 0 || firstDateSec == lastDateSec) {
        throw Exception('Dados inválidos');
      }

      final years = (lastDateSec - firstDateSec) / (365.25 * 24 * 3600);
      if (years < 0.5) throw Exception('Período muito curto');

      final cagr = pow(lastClose / firstClose, 1 / years).toDouble() - 1;
      // Sanity check: CAGR entre -50% e +200% a.a.
      if (cagr < -0.5 || cagr > 2.0) throw Exception('CAGR fora do esperado');
      return cagr;
    } catch (e) {
      debugPrint('[MarketAPI] CAGR fallback para $ticker: $e');
      return _defaultCagr(type);
    }
  }

  double _defaultCagr(AssetType type) => switch (type) {
    AssetType.stock => 0.12,
    AssetType.fii => 0.08,
    AssetType.fixedIncome => _cdiAnnualRate,
  };

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
