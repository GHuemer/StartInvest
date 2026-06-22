import 'package:injectable/injectable.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/missions_repository.dart';
import '../datasources/missions_remote_datasource.dart';
import '../models/mission_model.dart';

@LazySingleton(as: MissionsRepository)
class MissionsRepositoryImpl implements MissionsRepository {
  final MissionsRemoteDataSource remoteDataSource;

  MissionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MissionEntity>> getMissions() async {
    try {
      final catalogData = await remoteDataSource.getMissionsCatalog();
      return catalogData
          .map((json) => MissionModel.fromFirestore(json, json['id']))
          .toList();
    } catch (e) {
      // Em uma implementação real, trataríamos erros com um Either ou lançando Exceptions personalizadas
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      return await remoteDataSource.getUserProgress();
    } catch (e) {
      return {};
    }
  }
}
