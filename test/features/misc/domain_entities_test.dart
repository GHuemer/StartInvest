import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:startinvest/features/content/domain/entities/article.dart';
import 'package:startinvest/features/content/domain/entities/course.dart';
import 'package:startinvest/features/home/domain/entities/challenge.dart';
import 'package:startinvest/features/missions/domain/entities/mission_entity.dart';
import 'package:startinvest/features/news/domain/entities/news_entry.dart';
import 'package:startinvest/features/profile/domain/entities/league_info.dart';
import 'package:startinvest/features/profile/domain/entities/user_profile.dart';

void main() {
  group('Article', () {
    test('igualdade por valor', () {
      final a = Article(
        id: '1',
        title: 'T',
        content: 'C',
        author: 'A',
        readingTime: '5 min',
        publishedAt: DateTime(2024),
      );
      final b = Article(
        id: '1',
        title: 'T',
        content: 'C',
        author: 'A',
        readingTime: '5 min',
        publishedAt: DateTime(2024),
      );
      expect(a, b);
      expect(a.imageUrl, isNull);
    });
  });

  group('Course', () {
    test('campos opcionais sao nulos por padrao', () {
      const c = Course(id: '1', title: 'Curso');
      expect(c.videoUrl, isNull);
      expect(c.thumbnailUrl, isNull);
      expect(c, const Course(id: '1', title: 'Curso'));
    });
  });

  group('Challenge', () {
    test('valores padrao e props', () {
      const c = Challenge(
        id: '1',
        tag: 'tag',
        title: 'T',
        description: 'D',
        points: 100,
      );
      expect(c.iconType, 'emoji_events');
      expect(c.isRealIcon, false);
      // actualIcon nao entra em props (igualdade ignora)
      expect(c, const Challenge(
        id: '1',
        tag: 'tag',
        title: 'T',
        description: 'D',
        points: 100,
        actualIcon: 'qualquer',
      ));
    });
  });

  group('MissionEntity', () {
    const mission = MissionEntity(
      id: 'm1',
      title: 'Missao',
      description: 'desc',
      icon: Icons.star,
      category: MissionCategory.learning,
    );

    test('flags de status', () {
      expect(mission.isLocked, true);
      expect(mission.isCompleted, false);
      expect(mission.rewardPoints, 50);
    });

    test('copyWith atualiza status e progresso', () {
      final updated =
          mission.copyWith(status: MissionStatus.completed, progress: 1.0);
      expect(updated.isCompleted, true);
      expect(updated.isLocked, false);
      expect(updated.progress, 1.0);
      expect(updated.id, 'm1');
    });
  });

  group('NewsEntry', () {
    test('igualdade por valor', () {
      const a = NewsEntry(
        id: '1',
        title: 'T',
        content: 'C',
        source: 'S',
        date: 'hoje',
        tag: 'tag',
        category: 'cat',
      );
      const b = NewsEntry(
        id: '1',
        title: 'T',
        content: 'C',
        source: 'S',
        date: 'hoje',
        tag: 'tag',
        category: 'cat',
      );
      expect(a, b);
    });
  });

  group('LeagueInfo', () {
    test('getLeagueByXp escolhe a liga correta por faixa de XP', () {
      expect(LeagueInfo.getLeagueByXp(0).name, 'bronze');
      expect(LeagueInfo.getLeagueByXp(499).name, 'bronze');
      expect(LeagueInfo.getLeagueByXp(500).name, 'prata');
      expect(LeagueInfo.getLeagueByXp(1500).name, 'ouro');
      expect(LeagueInfo.getLeagueByXp(4000).name, 'elite');
    });

    test('getLeagueByName e case-insensitive e cai no padrao', () {
      expect(LeagueInfo.getLeagueByName('OURO').name, 'ouro');
      expect(LeagueInfo.getLeagueByName('inexistente').name, 'bronze');
    });

    test('lista possui 4 ligas', () {
      expect(LeagueInfo.leagues.length, 4);
    });
  });

  group('UserProfile', () {
    const profile = UserProfile(
      id: 'u1',
      username: 'joao',
      name: 'Joao',
      email: 'joao@test.com',
      xp: 100,
      level: 2,
      league: 'prata',
      subtitle: 'sub',
      completedCoursesCount: 3,
      balance: 1000,
      assetTypesCount: 2,
      loginStreak: 5,
      completedMissionsIds: ['m1'],
      memberSince: '2024',
    );

    test('friendIds vazio por padrao', () {
      expect(profile.friendIds, isEmpty);
    });

    test('copyWith altera campos mutaveis e preserva imutaveis', () {
      final updated = profile.copyWith(xp: 200, balance: 2000, league: 'ouro');
      expect(updated.xp, 200);
      expect(updated.balance, 2000);
      expect(updated.league, 'ouro');
      expect(updated.id, 'u1');
      expect(updated.email, 'joao@test.com');
      expect(updated.memberSince, '2024');
    });
  });
}
