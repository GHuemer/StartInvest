import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'social_sign_in_button.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialSignInButton(
          label: 'Continuar com o Google',
          icon: Icons.g_mobiledata,
          onPressed: () => context
              .read<AuthBloc>()
              .add(const AuthSignInWithGoogleRequested()),
        ),
        const SizedBox(height: 12),
        SocialSignInButton(
          label: 'Continuar com a Apple',
          icon: Icons.apple,
          onPressed: () {},
        ),
      ],
    );
  }
}
