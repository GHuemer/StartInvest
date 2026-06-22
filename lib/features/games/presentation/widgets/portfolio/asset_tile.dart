import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/market_asset.dart';
import '../../../domain/entities/position.dart';
import '../../../../../core/theme/app_colors.dart';

class AssetTile extends StatelessWidget {
  final MarketAsset asset;
  final VoidCallback onTap;

  const AssetTile({super.key, required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositive = asset.changePercent >= 0;
    final changeColor = isPositive
        ? AppColors.textPositive
        : AppColors.textNegative;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _typeColor(asset.type).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            asset.ticker.length > 4
                ? asset.ticker.substring(0, 4)
                : asset.ticker,
            style: TextStyle(
              color: _typeColor(asset.type),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
      title: Text(
        asset.ticker,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        asset.name,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            asset.type == AssetType.fixedIncome
                ? '${fmt.format(asset.currentPrice)}/cota'
                : fmt.format(asset.currentPrice),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%',
            style: TextStyle(color: changeColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Color _typeColor(AssetType type) {
    switch (type) {
      case AssetType.stock:
        return AppColors.primary;
      case AssetType.fii:
        return AppColors.yellowHighlight;
      case AssetType.fixedIncome:
        return AppColors.accentOrange;
    }
  }
}
