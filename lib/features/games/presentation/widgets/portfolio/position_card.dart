import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/position.dart';
import '../../../../../core/theme/app_colors.dart';

class PositionCard extends StatelessWidget {
  final Position position;
  final VoidCallback onTap;

  const PositionCard({super.key, required this.position, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isPositive = position.profitLoss >= 0;
    final returnColor = isPositive
        ? AppColors.textPositive
        : AppColors.textNegative;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _typeColor(position.assetType).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  position.ticker.substring(0, 2),
                  style: TextStyle(
                    color: _typeColor(position.assetType),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        position.ticker,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        fmt.format(position.currentValue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${position.quantity.toStringAsFixed(position.quantity % 1 == 0 ? 0 : 2)} un × ${fmt.format(position.currentPrice)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${position.profitLossPct.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: returnColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
