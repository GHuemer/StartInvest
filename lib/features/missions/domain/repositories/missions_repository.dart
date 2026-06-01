import '../entities/mission_entity.dart';

abstract class MissionsRepository {
  Future<List<MissionEntity>> getMissions();
  Future<Map<String, dynamic>> getUserProgress();
}
