import 'package:equatable/equatable.dart';
import '../../domain/entities/mission_entity.dart';

class MissionsState extends Equatable {
  final List<MissionEntity> allMissions;
  final List<MissionEntity> filteredMissions;
  final MissionCategory activeFilter;
  final bool isLoading;

  const MissionsState({
    this.allMissions = const [],
    this.filteredMissions = const [],
    this.activeFilter = MissionCategory.all,
    this.isLoading = false,
  });

  int get completedCount => allMissions.where((m) => m.isCompleted).length;
  double get totalProgress => allMissions.isEmpty ? 0 : completedCount / allMissions.length;

  MissionsState copyWith({
    List<MissionEntity>? allMissions,
    List<MissionEntity>? filteredMissions,
    MissionCategory? activeFilter,
    bool? isLoading,
  }) {
    return MissionsState(
      allMissions: allMissions ?? this.allMissions,
      filteredMissions: filteredMissions ?? this.filteredMissions,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [allMissions, filteredMissions, activeFilter, isLoading];
}
