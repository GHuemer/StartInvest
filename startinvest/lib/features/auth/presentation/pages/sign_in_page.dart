import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/social_sign_in_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.textNegative),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 32),
                _buildEmailForm(),
                const SizedBox(height: 16),
                _buildForgotPassword(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildSocialButtons(),
                const SizedBox(height: 24),
                _buildRegister(),
                const SizedBox(height: 16),
                _buildTerms(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8BC34A), Color(0xFFFFD600)],
            ),
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('START', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2)),
                Icon(Icons.show_chart, color: AppColors.backgroundDark, size: 32),
                Text('INVEST', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'START', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white)),
              TextSpan(text: ' INVEST', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: AppColors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Text('Fazer login', style: AppTextStyles.headlineMedium),
        SizedBox(height: 8),
        Text(
          'Insira seu e-mail caso já tenha uma conta',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(hintText: 'email@dominio.com'),
            validator: (v) => v == null || !v.contains('@') ? 'Email inválido' : null,
          ),
          const SizedBox(height: 12),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _onContinue,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                    : const Text('Continuar'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {},
      child: const Text('Esqueci a senha', style: AppTextStyles.bodyMedium),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('ou', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SocialSignInButton(
          label: 'Continuar com o Google',
          icon: Icons.g_mobiledata,
          onPressed: () => context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested()),
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

  Widget _buildRegister() {
    return TextButton(
      onPressed: () {},
      child: const Text('Registrar-se', style: AppTextStyles.titleMedium),
    );
  }

  Widget _buildTerms() {
    return Text(
      'Ao continuar, você concorda com os nossos\nTermos de Serviço e com a Política de Privacidade',
      style: AppTextStyles.bodySmall,
      textAlign: TextAlign.center,
    );
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignInWithEmailRequested(
              email: _emailController.text.trim(),
              password: '',
            ),
          );
    }
  }
}
