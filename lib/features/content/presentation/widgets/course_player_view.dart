import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';

class CoursePlayerView extends StatelessWidget {
  final String title;
  final String? videoUrl;

  const CoursePlayerView({super.key, required this.title, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final hasContent = videoUrl != null && videoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: AppTextStyles.titleLarge),
        leading: const AppBackButton(color: AppColors.white),
      ),
      body: Center(
        child: hasContent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Player de Vídeo: $title',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('URL: $videoUrl', style: AppTextStyles.bodyMedium),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ops, parece que ainda não tem conteúdo nessa aba!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
