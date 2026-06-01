// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:startinvest/features/missions/data/datasources/missions_remote_datasource.dart'
    as _i924;
import 'package:startinvest/features/missions/data/repositories/missions_repository_impl.dart'
    as _i754;
import 'package:startinvest/features/missions/domain/repositories/missions_repository.dart'
    as _i393;
import 'package:startinvest/features/missions/presentation/bloc/missions_cubit.dart'
    as _i284;

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
    gh.lazySingleton<_i393.MissionsRepository>(
      () => _i754.MissionsRepositoryImpl(
        remoteDataSource: gh<_i924.MissionsRemoteDataSource>(),
      ),
    );
    gh.factory<_i284.MissionsCubit>(
      () => _i284.MissionsCubit(gh<_i393.MissionsRepository>()),
    );
    return this;
  }
}
