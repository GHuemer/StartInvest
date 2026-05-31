import '../../domain/entities/challenge.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/challenge_model.dart';

class HomeRepositoryImpl implements HomeRepository {
   //injetar o FirebaseFirestore aqui
  // final FirebaseFirestore _firestore;
  // HomeRepositoryImpl(this._firestore);

  @override
  Future<Challenge> getDailyChallenge() async {
    try {

      // Enquanto não tem back, retornamos um mock para a UI não quebrar
      await Future.delayed(const Duration(milliseconds: 500));
      return const ChallengeModel(
        id: 'mock_1',
        tag: 'Novo Desafio',
        title: 'Conquiste 500pts',
        description: 'Complete o módulo de Tesouro Direto.',
        points: 500,
        iconType: 'emoji_events',
      );
    } catch (e) {
      throw Exception('Erro ao buscar desafio: $e');
    }
  }
}
