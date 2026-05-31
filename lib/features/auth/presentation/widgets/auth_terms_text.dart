import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthTermsText extends StatelessWidget {
  const AuthTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Ao continuar, você concorda com os nossos\nTermos de Serviço e com a Política de Privacidade',
      style: AppTextStyles.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}
