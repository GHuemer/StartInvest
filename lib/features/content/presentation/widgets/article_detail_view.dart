import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../domain/entities/article.dart';

class ArticleDetailView extends StatelessWidget {
  final Article article;

  const ArticleDetailView({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: article.imageUrl != null ? 240 : 100,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            leading: const AppBackButton(color: AppColors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: article.imageUrl != null
                  ? Image.network(article.imageUrl!, fit: BoxFit.cover)
                  : null,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: AppTextStyles.displayMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(article.author, style: AppTextStyles.bodySmall),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(article.readingTime, style: AppTextStyles.bodySmall),
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('dd/MM/yyyy').format(article.publishedAt),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 24),
                  Text(
                    article.content,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
