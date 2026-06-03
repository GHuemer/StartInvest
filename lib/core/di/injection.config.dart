// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:startinvest/features/auth/data/repositories/auth_repository_impl.dart'
    as _i943;
import 'package:startinvest/features/auth/domain/repositories/auth_repository.dart'
    as _i193;
import 'package:startinvest/features/auth/domain/usecases/send_password_reset_email.dart'
    as _i769;
import 'package:startinvest/features/auth/domain/usecases/sign_in_email.dart'
    as _i277;
import 'package:startinvest/features/auth/domain/usecases/sign_in_google.dart'
    as _i632;
import 'package:startinvest/features/auth/domain/usecases/sign_out.dart'
    as _i456;
import 'package:startinvest/features/auth/domain/usecases/sign_up.dart'
    as _i184;
import 'package:startinvest/features/auth/presentation/bloc/auth_bloc.dart'
    as _i968;
import 'package:startinvest/features/missions/data/datasources/missions_remote_datasource.dart'
    as _i924;
import 'package:startinvest/features/missions/data/repositories/missions_repository_impl.dart'
    as _i754;
import 'package:startinvest/features/missions/domain/repositories/missions_repository.dart'
    as _i393;
import 'package:startinvest/features/missions/presentation/bloc/missions_cubit.dart'
    as _i284;
import 'package:startinvest/features/news/data/datasources/news_remote_datasource.dart'
    as _i767;
import 'package:startinvest/features/news/data/repositories/news_repository_impl.dart'
    as _i1036;
import 'package:startinvest/features/news/domain/repositories/news_repository.dart'
    as _i11;
import 'package:startinvest/features/news/presentation/bloc/news_cubit.dart'
    as _i412;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i924.MissionsRemoteDataSource>(
      () => _i924.MissionsRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i767.NewsRemoteDataSource>(
      () => _i767.NewsRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i393.MissionsRepository>(
      () => _i754.MissionsRepositoryImpl(
        remoteDataSource: gh<_i924.MissionsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i193.AuthRepository>(
      () => _i943.AuthRepositoryImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        googleSignIn: gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i284.MissionsCubit>(
      () => _i284.MissionsCubit(gh<_i393.MissionsRepository>()),
    );
    gh.lazySingleton<_i11.NewsRepository>(
      () => _i1036.NewsRepositoryImpl(gh<_i767.NewsRemoteDataSource>()),
    );
    gh.factory<_i769.SendPasswordResetEmail>(
      () => _i769.SendPasswordResetEmail(gh<_i193.AuthRepository>()),
    );
    gh.factory<_i277.SignInWithEmail>(
      () => _i277.SignInWithEmail(gh<_i193.AuthRepository>()),
    );
    gh.factory<_i632.SignInWithGoogle>(
      () => _i632.SignInWithGoogle(gh<_i193.AuthRepository>()),
    );
    gh.factory<_i456.SignOut>(() => _i456.SignOut(gh<_i193.AuthRepository>()));
    gh.factory<_i184.SignUp>(() => _i184.SignUp(gh<_i193.AuthRepository>()));
    gh.factory<_i968.AuthBloc>(
      () => _i968.AuthBloc(
        signInWithGoogle: gh<_i632.SignInWithGoogle>(),
        signInWithEmail: gh<_i277.SignInWithEmail>(),
        signOut: gh<_i456.SignOut>(),
        signUp: gh<_i184.SignUp>(),
        sendPasswordResetEmail: gh<_i769.SendPasswordResetEmail>(),
        authRepository: gh<_i193.AuthRepository>(),
      ),
    );
    gh.factory<_i412.NewsCubit>(
      () => _i412.NewsCubit(gh<_i11.NewsRepository>()),
    );
    return this;
  }
}
