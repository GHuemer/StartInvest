import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().asyncMap((
    firebaseUser,
  ) async {
    if (firebaseUser == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }

      // Se o documento não existe no Firestore, retornamos um usuário sem username.
      // NUNCA marcamos como isNewUser: true através do stream global, para evitar
      // redirecionamentos indesejados ao apenas "abrir o app".
      // O isNewUser: true virá apenas do retorno direto das funções de Sign In.
      return UserModel.fromFirebaseUser(firebaseUser, isNewUser: false);
    } catch (_) {
      return UserModel.fromFirebaseUser(firebaseUser, isNewUser: false);
    }
  });

  @override
  Future<Either<Failure, AppUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      if (doc.exists) {
        return Right(UserModel.fromMap(doc.data()!, doc.id));
      }
      // Se não existe documento para um login por e-mail, tratamos como usuário existente
      // para evitar redirecionamentos indesejados para completar perfil.
      return Right(UserModel.fromFirebaseUser(cred.user!, isNewUser: false));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapError(e.code)));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final UserCredential cred;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        cred = await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return const Left(AuthFailure('Login cancelado'));
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }

      final doc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      if (doc.exists) {
        return Right(UserModel.fromMap(doc.data()!, doc.id));
      }

      // Se não existe documento, retornamos o usuário sem username marcando como NOVO
      // A UI deve redirecionar para uma tela de "Escolha seu username"
      return Right(UserModel.fromFirebaseUser(cred.user!, isNewUser: true));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapError(e.code)));
    } catch (e) {
      return const Left(AuthFailure('Erro ao entrar com Google'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String username,
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
  }) async {
    try {
      // 1. Verificar se o username já existe
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        return const Left(AuthFailure('Este nome de usuário já está em uso'));
      }

      // 2. Criar no Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.updateDisplayName(name);

      // 3. Salvar no Firestore
      final user = UserModel(
        id: cred.user!.uid,
        username: username.toLowerCase().trim(),
        name: name,
        email: email,
        birthDate: birthDate,
      );

      final userMap = user.toMap();
      userMap['createdAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(user.id).set(userMap);

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapError(e.code)));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase().trim())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  @override
  Future<Either<Failure, void>> updateUsername(
    String userId,
    String username,
  ) async {
    try {
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        return const Left(AuthFailure('Este nome de usuário já está em uso'));
      }

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser == null)
          return const Left(AuthFailure('Usuário não autenticado'));

        // Se o documento não existe (caso de login social novo), criamos ele com os dados básicos e o novo username
        final model = UserModel.fromFirebaseUser(
          firebaseUser,
          username: username.toLowerCase().trim(),
        );
        final userMap = model.toMap();
        userMap['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(userId).set(userMap);
      } else {
        // Se já existe, apenas atualizamos o username
        await _firestore.collection('users').doc(userId).update({
          'username': username.toLowerCase().trim(),
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao atualizar nome de usuário'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapError(e.code)));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      return const Right(null);
    } catch (_) {
      return const Left(AuthFailure('Erro ao sair'));
    }
  }

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    // Nota: Aqui não temos acesso direto ao Firestore de forma síncrona
    // O ideal é usar o authStateChanges para pegar o usuário completo
    return user != null
        ? UserModel.fromFirebaseUser(user, isNewUser: false)
        : null;
  }

  @override
  Future<AppUser?> getFullCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return UserModel.fromFirebaseUser(firebaseUser, isNewUser: false);
    } catch (_) {
      return UserModel.fromFirebaseUser(firebaseUser, isNewUser: false);
    }
  }

  String _mapError(String code) => switch (code) {
    'user-not-found' => 'Usuário não encontrado',
    'wrong-password' => 'Senha incorreta',
    'invalid-credential' => 'E-mail ou senha incorretos',
    'email-already-in-use' => 'E-mail já cadastrado',
    'weak-password' => 'Senha muito fraca (mínimo 6 caracteres)',
    'invalid-email' => 'E-mail inválido',
    'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde',
    _ => 'Erro de autenticação',
  };
}
