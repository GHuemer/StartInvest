import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_terms_text.dart';
import '../widgets/forgot_password_button.dart';
import '../widgets/register_button.dart';
import '../widgets/sign_in_email_form.dart';
import '../widgets/sign_in_title.dart';
import '../widgets/social_auth_section.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.textNegative),
          );
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 48),
                AuthLogo(),
                SizedBox(height: 40),
                SignInTitle(),
                SizedBox(height: 32),
                SignInEmailForm(),
                SizedBox(height: 16),
                ForgotPasswordButton(),
                SizedBox(height: 24),
                AuthDivider(),
                SizedBox(height: 24),
                SocialAuthSection(),
                SizedBox(height: 24),
                RegisterButton(),
                SizedBox(height: 16),
                AuthTermsText(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
