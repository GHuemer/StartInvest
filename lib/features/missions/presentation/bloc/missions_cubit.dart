import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/missions_repository.dart';
import 'missions_state.dart';

@injectable
class MissionsCubit extends Cubit<MissionsState> {
  final MissionsRepository _repository;

  MissionsCubit(this._repository) : super(const MissionsState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    try {
      // 1. Buscar catálogo de missões do Repositório
      final List<MissionEntity> catalog = await _repository.getMissions();

      // 2. Buscar progresso do usuário (Nível, Cursos, Saldo, etc)
      final progressData = await _repository.getUserProgress();

      final userLevel = progressData['level'] ?? 3; // Fallback para mock se o campo não existir
      final userCoursesCount = progressData['completedCoursesCount'] ?? 6;
      final userBalance = (progressData['balance'] ?? 850.0).toDouble();
      final userAssetTypes = progressData['assetTypesCount'] ?? 1;
      final userLoginStreak = progressData['loginStreak'] ?? 2;
      final List<dynamic> userCompletedMissions = progressData['completedMissionsIds'] ?? ['1', '3'];

      final updatedMissions = catalog.map((mission) {
        MissionStatus status = MissionStatus.locked;
        double progress = 0.0;

        if (userCompletedMissions.contains(mission.id)) {
          return mission.copyWith(status: MissionStatus.completed, progress: 1.0);
        }

        final canSee = userLevel >= mission.requiredLevel && userCoursesCount >= mission.requiredCourses;

        if (!canSee) {
          return mission.copyWith(status: MissionStatus.locked, progress: 0.0);
        }

        status = MissionStatus.available;
        
        switch (mission.id) {
          case '2': // Estudioso (5 módulos)
          progress = (userCoursesCount / 5).clamp(0.0, 1.0);
          break;
        case '4': // Diversificador (3 ativos)
          progress = (userAssetTypes / 3).clamp(0.0, 1.0);
          break;
        case '5': // Mestre da Renda Fixa (8 módulos)
          progress = (userCoursesCount / 8).clamp(0.0, 1.0);
          break;
        case '6': // Primeiro K (1.000 balance)
          progress = (userBalance / 1000.0).clamp(0.0, 1.0);
          break;
        case '7': // Fiel ao Mercado (3 dias)
          progress = (userLoginStreak / 3).clamp(0.0, 1.0);
          break;
        case '8': // Analista Pleno (15 módulos)
          progress = (userCoursesCount / 15).clamp(0.0, 1.0);
          break;
        case '9': // Baleia (50.000 balance)
          progress = (userBalance / 50000.0).clamp(0.0, 1.0);
          break;
        case '10': // Educador (10 módulos)
          progress = (userCoursesCount / 10).clamp(0.0, 1.0);
          break;
        case '11': // Milionário (1.000.000 balance)
          progress = (userBalance / 1000000.0).clamp(0.0, 1.0);
          break;
        case '12': // Estrategista (10 ativos)
          progress = (userAssetTypes / 10.0).clamp(0.0, 1.0);
          break;
        default:
          progress = 0.0;
        }

        if (progress >= 1.0) {
          status = MissionStatus.completed;
        }

        return mission.copyWith(status: status, progress: progress);
      }).toList();

      emit(state.copyWith(
        allMissions: updatedMissions,
        filteredMissions: updatedMissions,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void filterMissions(MissionCategory category) {
    final filtered = category == MissionCategory.all
        ? state.allMissions
        : state.allMissions.where((m) => m.category == category).toList();
    
    emit(state.copyWith(
      activeFilter: category,
      filteredMissions: filtered,
    ));
  }
}
