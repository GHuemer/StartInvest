import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_email.dart';
import 'features/auth/domain/usecases/sign_in_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const StartInvestApp());
}

class StartInvestApp extends StatelessWidget {
  const StartInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepositoryImpl();

    return BlocProvider(
      create: (_) => AuthBloc(
        signInWithGoogle: SignInWithGoogle(authRepository),
        signInWithEmail: SignInWithEmail(authRepository),
        signOut: SignOut(authRepository),
        authRepository: authRepository,
      )..add(const AuthStarted()),
      child: MaterialApp.router(
        title: 'StartInvest',
        theme: AppTheme.dark,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
