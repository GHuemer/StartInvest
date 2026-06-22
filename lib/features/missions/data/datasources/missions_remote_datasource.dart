import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

abstract class MissionsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMissionsCatalog();
  Future<Map<String, dynamic>> getUserProgress();
  Future<bool> completeMission(String missionId, int points);
}

@LazySingleton(as: MissionsRemoteDataSource)
class MissionsRemoteDataSourceImpl implements MissionsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MissionsRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<bool> completeMission(String missionId, int points) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = _firestore.collection('users').doc(user.uid);
    
    final doc = await userDoc.get();
    final data = doc.data() ?? {};
    final completedIds = List<String>.from(data['completedMissionsIds'] ?? []);

    if (completedIds.contains(missionId)) {
      return false;
    }

    // Calcula o novo XP garantindo que nunca fique negativo
    int currentXp = (data['xp'] ?? 0) as int;
    int newXp = currentXp + points;
    if (newXp < 0) {
      newXp = 0;
    }

    await userDoc.update({
      'xp': newXp,
      'completedMissionsIds': FieldValue.arrayUnion([missionId]),
    });

    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getMissionsCatalog() async {
    final snapshot = await _firestore.collection('missions_catalog').get();
    if (snapshot.docs.isEmpty) {
      return _getMockCatalog();
    }
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  @override
  Future<Map<String, dynamic>> getUserProgress() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return {};

    return doc.data() ?? {};
  }

  List<Map<String, dynamic>> _getMockCatalog() {
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
}
