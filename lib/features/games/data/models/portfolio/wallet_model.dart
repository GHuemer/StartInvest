import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.startingBalance,
    required super.availableBalance,
    required super.createdAt,
    super.lastPortfolioValue,
  });

  factory WalletModel.fromFirestore(String id, Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      startingBalance: (data['startingBalance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (data['availableBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastPortfolioValue:
          (data['lastPortfolioValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'startingBalance': startingBalance,
    'availableBalance': availableBalance,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
