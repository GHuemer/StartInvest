import 'package:injectable/injectable.dart';

abstract class MissionsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMissionsCatalog();
  Future<Map<String, dynamic>> getUserProgress();
}

@LazySingleton(as: MissionsRemoteDataSource)
class MissionsRemoteDataSourceImpl implements MissionsRemoteDataSource {
  MissionsRemoteDataSourceImpl();

  @override
  Future<List<Map<String, dynamic>>> getMissionsCatalog() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      {
        'id': '1',
        'title': 'Primeiro Passo',
        'description': 'Assista sua primeira aula no app',
        'icon': 'play',
        'category': 'learning',
        'requiredLevel': 0,
        'requiredCourses': 0,
      },
      {
        'id': '2',
        'title': 'Estudioso',
        'description': 'Conclua 5 módulos de cursos',
        'icon': 'book',
        'category': 'learning',
        'requiredLevel': 2,
        'requiredCourses': 5,
      },
      {
        'id': '3',
        'title': 'Investidor Iniciante',
        'description': 'Realize sua primeira simulação de compra',
        'icon': 'trending',
        'category': 'practice',
        'requiredLevel': 1,
        'requiredCourses': 0,
      },
      {
        'id': '4',
        'title': 'Diversificador',
        'description': 'Tenha 3 tipos de ativos diferentes no simulador',
        'icon': 'pie',
        'category': 'practice',
        'requiredLevel': 3,
        'requiredCourses': 0,
      },
      {
        'id': '5',
        'title': 'Mestre da Renda Fixa',
        'description': 'Conclua o curso de Tesouro Direto',
        'icon': 'bank',
        'category': 'learning',
        'requiredLevel': 4,
        'requiredCourses': 8,
      },
      {
        'id': '6',
        'title': 'Primeiro K',
        'description': 'Alcance R\$ 1.000,00 de patrimônio simulado',
        'icon': 'savings',
        'category': 'practice',
        'requiredLevel': 2,
        'requiredCourses': 0,
      },
      {
        'id': '7',
        'title': 'Fiel ao Mercado',
        'description': 'Acesse o app por 3 dias seguidos',
        'icon': 'calendar',
        'category': 'practice',
        'requiredLevel': 0,
        'requiredCourses': 0,
      },
      {
        'id': '8',
        'title': 'Analista Pleno',
        'description': 'Conclua 15 módulos de cursos avançados',
        'icon': 'analytics',
        'category': 'learning',
        'requiredLevel': 7,
        'requiredCourses': 15,
      },
      {
        'id': '9',
        'title': 'Baleia do Simulador',
        'description': 'Alcance R\$ 50.000,00 de patrimônio simulado',
        'icon': 'waves',
        'category': 'practice',
        'requiredLevel': 10,
        'requiredCourses': 0,
      },
      {
        'id': '10',
        'title': 'Educador Financeiro',
        'description': 'Conclua todos os cursos básicos',
        'icon': 'school',
        'category': 'learning',
        'requiredLevel': 5,
        'requiredCourses': 10,
      },
      {
        'id': '11',
        'title': 'Milionário',
        'description': 'Alcance R\$ 1.000.000,00 de patrimônio simulado',
        'icon': 'savings',
        'category': 'practice',
        'requiredLevel': 15,
        'requiredCourses': 0,
      },
      {
        'id': '12',
        'title': 'Estrategista',
        'description': 'Tenha 10 tipos de ativos diferentes no simulador',
        'icon': 'pie',
        'category': 'practice',
        'requiredLevel': 8,
        'requiredCourses': 0,
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'level': 3,
      'completedCoursesCount': 6,
      'balance': 850.0,
      'assetTypesCount': 1,
      'loginStreak': 2,
      'completedMissionsIds': ['1', '3'],
    };
  }
}
