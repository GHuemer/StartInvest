import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/simulation_result.dart';
import '../models/portfolio/wallet_model.dart';
import '../models/portfolio/position_model.dart';
import '../models/portfolio/trade_model.dart';

abstract class PortfolioFirestoreDataSource {
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> createWallet(String name, double startingBalance);
  Future<List<PositionModel>> getPositions(String walletId);
  Future<List<TradeModel>> getTrades(String walletId);
  Future<void> deleteWallet(String walletId);
  Future<void> syncWalletBalance(
    String walletId,
    List<Position> updatedPositions,
    double updatedAvailableBalance,
  );
  Future<void> awardXp(int xp);
  Future<void> saveProjectionHistory(SimulationResult result);
  Future<List<SimulationResult>> getProjectionHistory();
  Future<TradeModel> buyAsset({
    required String walletId,
    required String ticker,
    required AssetType assetType,
    required double quantity,
    required double price,
  });
  Future<TradeModel> sellAsset({
    required String walletId,
    required String ticker,
    required double quantity,
    required double price,
    required int xpEarned,
  });
}

@LazySingleton(as: PortfolioFirestoreDataSource)
class PortfolioFirestoreDataSourceImpl implements PortfolioFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PortfolioFirestoreDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _wallets =>
      _firestore.collection('users').doc(_uid).collection('wallets');

  @override
  Future<List<WalletModel>> getWallets() async {
    final snap = await _wallets.orderBy('createdAt').get();
    return snap.docs
        .map(
          (d) =>
              WalletModel.fromFirestore(d.id, d.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<WalletModel> createWallet(String name, double startingBalance) async {
    final data = {
      'userId': _uid,
      'name': name,
      'startingBalance': startingBalance,
      'availableBalance': startingBalance,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final ref = await _wallets.add(data);
    final snap = await ref.get();
    return WalletModel.fromFirestore(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );
  }

  @override
  Future<List<PositionModel>> getPositions(String walletId) async {
    final snap = await _wallets.doc(walletId).collection('positions').get();
    return snap.docs
        .map((d) => PositionModel.fromFirestore(d.id, d.data(), walletId))
        .toList();
  }

  @override
  Future<List<TradeModel>> getTrades(String walletId) async {
    final snap = await _wallets
        .doc(walletId)
        .collection('trades')
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs
        .map((d) => TradeModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  @override
  Future<TradeModel> buyAsset({
    required String walletId,
    required String ticker,
    required AssetType assetType,
    required double quantity,
    required double price,
  }) async {
    final totalValue = quantity * price;
    final walletRef = _wallets.doc(walletId);
    final posRef = walletRef.collection('positions').doc(ticker);

    await _firestore.runTransaction((tx) async {
      final walletSnap = await tx.get(walletRef);
      final posSnap = await tx.get(posRef);

      final currentBalance =
          (walletSnap.data() as Map<String, dynamic>)['availableBalance']
              as double;

      if (posSnap.exists) {
        final existing = posSnap.data() as Map<String, dynamic>;
        final existingQty = (existing['quantity'] as num).toDouble();
        final existingAvg = (existing['avgBuyPrice'] as num).toDouble();
        final newQty = existingQty + quantity;
        final newAvg =
            ((existingAvg * existingQty) + (price * quantity)) / newQty;
        tx.update(posRef, {'quantity': newQty, 'avgBuyPrice': newAvg});
      } else {
        tx.set(posRef, {
          'ticker': ticker,
          'walletId': walletId,
          'assetType': assetType.value,
          'quantity': quantity,
          'avgBuyPrice': price,
          'createdAt': Timestamp.now(),
        });
      }

      tx.update(walletRef, {'availableBalance': currentBalance - totalValue});
    });

    final tradeData = {
      'walletId': walletId,
      'ticker': ticker,
      'assetType': assetType.value,
      'type': 'buy',
      'quantity': quantity,
      'price': price,
      'totalValue': totalValue,
      'timestamp': FieldValue.serverTimestamp(),
      'xpEarned': null,
    };
    final tradeRef = await walletRef.collection('trades').add(tradeData);

    await _updateUserBalance(walletId);

    final tradeSnap = await tradeRef.get();
    return TradeModel.fromFirestore(
      tradeSnap.id,
      tradeSnap.data() as Map<String, dynamic>,
    );
  }

  @override
  Future<TradeModel> sellAsset({
    required String walletId,
    required String ticker,
    required double quantity,
    required double price,
    required int xpEarned,
  }) async {
    final totalValue = quantity * price;
    final walletRef = _wallets.doc(walletId);
    final posRef = walletRef.collection('positions').doc(ticker);
    String? assetTypeStr;

    await _firestore.runTransaction((tx) async {
      final walletSnap = await tx.get(walletRef);
      final posSnap = await tx.get(posRef);

      final posData = posSnap.data() as Map<String, dynamic>;
      assetTypeStr = posData['assetType'] as String?;
      final currentQty = (posData['quantity'] as num).toDouble();
      final currentBalance =
          (walletSnap.data() as Map<String, dynamic>)['availableBalance']
              as double;

      if (currentQty - quantity < 0.0001) {
        tx.delete(posRef);
      } else {
        tx.update(posRef, {'quantity': currentQty - quantity});
      }

      tx.update(walletRef, {'availableBalance': currentBalance + totalValue});
    });

    if (xpEarned != 0) {
      await _firestore.collection('users').doc(_uid).update({
        'xp': FieldValue.increment(xpEarned),
      });
    }

    final tradeData = {
      'walletId': walletId,
      'ticker': ticker,
      'assetType': assetTypeStr ?? 'stock',
      'type': 'sell',
      'quantity': quantity,
      'price': price,
      'totalValue': totalValue,
      'timestamp': FieldValue.serverTimestamp(),
      'xpEarned': xpEarned,
    };
    final tradeRef = await walletRef.collection('trades').add(tradeData);

    await _updateUserBalance(walletId);

    final tradeSnap = await tradeRef.get();
    return TradeModel.fromFirestore(
      tradeSnap.id,
      tradeSnap.data() as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    final walletRef = _wallets.doc(walletId);

    // Firestore não apaga subcoleções automaticamente — delete manual
    final positions = await walletRef.collection('positions').get();
    for (final doc in positions.docs) {
      await doc.reference.delete();
    }
    final trades = await walletRef.collection('trades').get();
    for (final doc in trades.docs) {
      await doc.reference.delete();
    }
    await walletRef.delete();
  }

  @override
  Future<void> syncWalletBalance(
    String walletId,
    List<Position> updatedPositions,
    double updatedAvailableBalance,
  ) async {
    final allWallets = await getWallets();
    double totalBalance = 0;
    final Set<String> assetTypes = {};

    for (final w in allWallets) {
      if (w.id == walletId) {
        final walletPortfolioValue = updatedAvailableBalance +
            updatedPositions.fold(0.0, (s, p) => s + p.quantity * p.currentPrice);
        totalBalance += walletPortfolioValue;
        for (final p in updatedPositions) {
          assetTypes.add(p.assetType.value);
        }
        await _wallets.doc(walletId).update({
          'lastPortfolioValue': walletPortfolioValue,
        });
      } else {
        totalBalance += w.availableBalance;
        final positions = await getPositions(w.id);
        for (final p in positions) {
          totalBalance += p.quantity * p.avgBuyPrice;
          assetTypes.add(p.assetType.value);
        }
      }
    }

    await _firestore.collection('users').doc(_uid).update({
      'balance': totalBalance,
      'assetTypesCount': assetTypes.length,
    });
  }

  @override
  Future<void> awardXp(int xp) async {
    await _firestore.collection('users').doc(_uid).update({
      'xp': FieldValue.increment(xp),
    });
  }

  CollectionReference get _projectionHistory =>
      _firestore.collection('users').doc(_uid).collection('projection_history');

  @override
  Future<void> saveProjectionHistory(SimulationResult result) async {
    final col = _projectionHistory;

    // Limita a 50 entradas: apaga a mais antiga se necessário
    final count = await col.count().get();
    if ((count.count ?? 0) >= 50) {
      final oldest = await col.orderBy('createdAt').limit(1).get();
      for (final doc in oldest.docs) {
        await doc.reference.delete();
      }
    }

    await col.add({
      'createdAt': FieldValue.serverTimestamp(),
      'periodMonths': result.periodMonths,
      'periodLabel': result.periodLabel,
      'consolidatedPoints': result.consolidatedPoints,
      'assets': result.assets
          .map((a) => {
                'ticker': a.ticker,
                'name': a.name,
                'assetType': a.assetType.value,
                'investedAmount': a.investedAmount,
                'annualRate': a.annualRate,
                'dataPoints': a.dataPoints,
              })
          .toList(),
    });
  }

  @override
  Future<List<SimulationResult>> getProjectionHistory() async {
    final snap = await _projectionHistory
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final assetsRaw = data['assets'] as List? ?? [];
      final assets = assetsRaw.map((a) {
        final map = a as Map<String, dynamic>;
        final rawPoints = map['dataPoints'] as List? ?? [];
        return AssetProjection(
          ticker: map['ticker'] as String,
          name: map['name'] as String,
          assetType: AssetTypeLabel.fromString(map['assetType'] as String),
          investedAmount: (map['investedAmount'] as num).toDouble(),
          annualRate: (map['annualRate'] as num).toDouble(),
          dataPoints:
              rawPoints.map((v) => (v as num).toDouble()).toList(),
        );
      }).toList();

      final rawConsolidated = data['consolidatedPoints'] as List? ?? [];
      return SimulationResult(
        assets: assets,
        periodMonths: (data['periodMonths'] as num).toInt(),
        periodLabel: data['periodLabel'] as String,
        consolidatedPoints:
            rawConsolidated.map((v) => (v as num).toDouble()).toList(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  Future<void> _updateUserBalance(String walletId) async {
    final allWallets = await getWallets();
    double totalBalance = 0;
    int assetTypesSet = 0;

    final Set<String> assetTypes = {};
    for (final w in allWallets) {
      totalBalance += w.availableBalance;
      final positions = await getPositions(w.id);
      for (final p in positions) {
        totalBalance += p.quantity * p.avgBuyPrice;
        assetTypes.add(p.assetType.value);
      }
    }
    assetTypesSet = assetTypes.length;

    await _firestore.collection('users').doc(_uid).update({
      'balance': totalBalance,
      'assetTypesCount': assetTypesSet,
    });
  }
}
