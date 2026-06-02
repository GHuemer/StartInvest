import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/news_entry.dart';

class NewsCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  Color _getTagColor() {
    switch (news.category) {
      case 'stocks':
        return AppColors.tagStocks;
      case 'crypto':
        return AppColors.tagCrypto;
      case 'economy':
        return AppColors.tagEconomy;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTagColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getTagColor().withOpacity(0.5)),
                  ),
                  child: Text(
                    news.tag,
                    style: TextStyle(
                      color: _getTagColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  news.date,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              news.title,
              style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              news.content,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fonte: ${news.source}',
                  style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
                ),
                Row(
                  children: [
                    Text(
                      'Ler mais',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
