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

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/send_password_reset_email.dart'
    as _i238;
import '../../features/auth/domain/usecases/sign_in_email.dart' as _i1048;
import '../../features/auth/domain/usecases/sign_in_google.dart' as _i770;
import '../../features/auth/domain/usecases/sign_out.dart' as _i568;
import '../../features/auth/domain/usecases/sign_up.dart' as _i190;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/missions/data/datasources/missions_remote_datasource.dart'
    as _i908;
import '../../features/missions/data/repositories/missions_repository_impl.dart'
    as _i382;
import '../../features/missions/domain/repositories/missions_repository.dart'
    as _i83;
import '../../features/missions/presentation/bloc/missions_cubit.dart'
    as _i1044;
import '../../features/news/data/datasources/news_remote_datasource.dart'
    as _i173;
import '../../features/news/data/repositories/news_repository_impl.dart'
    as _i164;
import '../../features/news/domain/repositories/news_repository.dart' as _i258;
import '../../features/news/presentation/bloc/news_cubit.dart' as _i103;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/presentation/profile_cubit.dart' as _i666;
import '../../features/ranking/presentation/bloc/ranking_cubit.dart' as _i448;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i974.FirebaseFirestore>(() => registerModule.firestore);
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.lazySingleton<_i173.NewsRemoteDataSource>(
      () => _i173.NewsRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i908.MissionsRemoteDataSource>(
      () => _i908.MissionsRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i83.MissionsRepository>(
      () => _i382.MissionsRepositoryImpl(
        remoteDataSource: gh<_i908.MissionsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        googleSignIn: gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i1044.MissionsCubit>(
      () => _i1044.MissionsCubit(gh<_i83.MissionsRepository>()),
    );
    gh.lazySingleton<_i258.NewsRepository>(
      () => _i164.NewsRepositoryImpl(gh<_i173.NewsRemoteDataSource>()),
    );
    gh.factory<_i666.ProfileCubit>(
      () => _i666.ProfileCubit(
        gh<_i787.AuthRepository>(),
        gh<_i894.ProfileRepository>(),
      ),
    );
    gh.factory<_i238.SendPasswordResetEmail>(
      () => _i238.SendPasswordResetEmail(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1048.SignInWithEmail>(
      () => _i1048.SignInWithEmail(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i770.SignInWithGoogle>(
      () => _i770.SignInWithGoogle(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i568.SignOut>(() => _i568.SignOut(gh<_i787.AuthRepository>()));
    gh.factory<_i190.SignUp>(() => _i190.SignUp(gh<_i787.AuthRepository>()));
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        signInWithGoogle: gh<_i770.SignInWithGoogle>(),
        signInWithEmail: gh<_i1048.SignInWithEmail>(),
        signOut: gh<_i568.SignOut>(),
        signUp: gh<_i190.SignUp>(),
        sendPasswordResetEmail: gh<_i238.SendPasswordResetEmail>(),
        authRepository: gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i103.NewsCubit>(
      () => _i103.NewsCubit(gh<_i258.NewsRepository>()),
    );
    gh.factory<_i448.RankingCubit>(
      () => _i448.RankingCubit(
        gh<_i894.ProfileRepository>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
