import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return Right(UserProfileModel.fromFirestore(doc));
      } else {
        return Left(ServerFailure('Perfil não encontrado'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel(
        id: profile.id,
        username: profile.username,
        name: profile.name,
        email: profile.email,
        photoUrl: profile.photoUrl,
        xp: profile.xp,
        level: profile.level,
        league: profile.league,
        subtitle: profile.subtitle,
        completedCoursesCount: profile.completedCoursesCount,
        balance: profile.balance,
        assetTypesCount: profile.assetTypesCount,
        loginStreak: profile.loginStreak,
        completedMissionsIds: profile.completedMissionsIds,
        friendIds: profile.friendIds,
        memberSince: profile.memberSince,
      );
      await _firestore.collection('users').doc(profile.id).set(model.toFirestore(), SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getRanking() async {
    try {
      final query = await _firestore
          .collection('users')
          .orderBy('xp', descending: true)
          .limit(20)
          .get();
      
      final ranking = query.docs
          .map((doc) => UserProfileModel.fromFirestore(doc))
          .toList();
          
      return Right(ranking);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getFriendsRanking(List<String> friendIds) async {
    try {
      final cleanIds = friendIds.where((id) => id.isNotEmpty).take(30).toList();
      
      if (cleanIds.isEmpty) return const Right([]);

      // Busca os documentos individualmente para garantir que todos sejam encontrados
      final snapshots = await Future.wait(
        cleanIds.map((id) => _firestore.collection('users').doc(id).get())
      );

      final ranking = snapshots
          .where((doc) => doc.exists)
          .map((doc) => UserProfileModel.fromFirestore(doc))
          .toList();

      ranking.sort((a, b) => b.xp.compareTo(a.xp));

      return Right(ranking);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar ranking: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> searchUserByName(String name) async {
    try {
      var query = await _firestore
          .collection('users')
          .where('username', isEqualTo: name.toLowerCase().trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('users')
            .where('name', isEqualTo: name)
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) return const Right(null);
      
      return Right(UserProfileModel.fromFirestore(query.docs.first));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFriend(String userId, String friendId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'friendIds': FieldValue.arrayUnion([friendId]),
      });
      await _firestore.collection('users').doc(friendId).update({
        'friendIds': FieldValue.arrayUnion([userId]),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(String fromId, String toId) async {
    try {
      final fromDoc = await _firestore.collection('users').doc(fromId).get();
      if (!fromDoc.exists) {
        return Left(ServerFailure('Seu perfil não foi encontrado. Tente completar seu cadastro.'));
      }
      
      final fromData = fromDoc.data()!;
      
      // Verifica se já existe uma solicitação pendente
      final existing = await _firestore.collection('friend_requests')
          .where('fromId', isEqualTo: fromId)
          .where('toId', isEqualTo: toId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();
          
      if (existing.docs.isNotEmpty) {
        return Left(ServerFailure('Você já enviou uma solicitação para este usuário.'));
      }

      await _firestore.collection('friend_requests').add({
        'fromId': fromId,
        'toId': toId,
        'fromName': fromData['name'] ?? 'Usuário',
        'fromUsername': fromData['username'] ?? '',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao enviar solicitação: ${e.toString()}'));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchFriendRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('toId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'fromId': data['fromId'],
            'fromUser': {
              'name': data['fromName'],
              'username': data['fromUsername'],
            },
            'timestamp': data['timestamp'],
          };
        }).toList());
  }

  @override
  Future<Either<Failure, void>> respondToFriendRequest(String requestId, bool accept) async {
    try {
      final doc = await _firestore.collection('friend_requests').doc(requestId).get();
      if (!doc.exists) return Left(ServerFailure('Solicitação não encontrada'));
      
      final data = doc.data()!;
      final fromId = data['fromId'];
      final toId = data['toId'];

      if (accept) {
        await addFriend(fromId, toId);
        await _firestore.collection('friend_requests').doc(requestId).update({'status': 'accepted'});
      } else {
        await _firestore.collection('friend_requests').doc(requestId).update({'status': 'declined'});
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
