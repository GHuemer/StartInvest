import 'package:injectable/injectable.dart';
import '../../entities/position.dart';

@injectable
class CalculatePortfolioXpUseCase {
  int call({required AssetType assetType, required double profitLossPct}) {
    switch (assetType) {
      case AssetType.fixedIncome:
        return _conservativeXp(profitLossPct);
      case AssetType.fii:
        return _moderateXp(profitLossPct);
      case AssetType.stock:
        return _aggressiveXp(profitLossPct);
    }
  }

  int _conservativeXp(double pct) {
    if (pct < 0) return 0;
    if (pct < 2) return 5;
    if (pct < 5) return 10;
    return 20;
  }

  int _moderateXp(double pct) {
    if (pct < -5) return -10;
    if (pct < 0) return 0;
    if (pct < 5) return 25;
    if (pct < 10) return 40;
    return 60;
  }

  int _aggressiveXp(double pct) {
    if (pct < -15) return -30;
    if (pct < -5) return -10;
    if (pct < 0) return 0;
    if (pct < 10) return 50;
    if (pct < 25) return 75;
    return 120;
  }
}
