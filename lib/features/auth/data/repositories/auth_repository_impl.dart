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
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().asyncMap(
        (firebaseUser) async {
          if (firebaseUser == null) return null;
          try {
            final doc = await _firestore
                .collection('users')
                .doc(firebaseUser.uid)
                .get();
            if (doc.exists) return UserModel.fromMap(doc.data()!, doc.id);
            // Primeira vez (ex: Google Sign-In) — cria o documento
            final newUser = UserModel.fromFirebaseUser(firebaseUser);
            await _firestore
                .collection('users')
                .doc(firebaseUser.uid)
                .set(newUser.toMap());
            return newUser;
          } catch (_) {
            // Se Firestore falhar, usa os dados do Firebase Auth como fallback
            return UserModel.fromFirebaseUser(firebaseUser);
          }
        },
      );

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
      // authStateChanges cuida de buscar/criar o documento no Firestore
      return Right(UserModel.fromFirebaseUser(cred.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapError(e.code)));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final UserCredential cred;

      if (kIsWeb) {
        // Web: usa popup diretamente no Firebase Auth
        final provider = GoogleAuthProvider();
        cred = await _auth.signInWithPopup(provider);
      } else {
        // Android/iOS: usa o pacote google_sign_in
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

      // Retorna o usuário do Firebase Auth — o authStateChanges cuida do Firestore
      return Right(UserModel.fromFirebaseUser(cred.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapError(e.code)));
    } catch (e) {
      return const Left(AuthFailure('Erro ao entrar com Google'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);
      final user = UserModel(id: cred.user!.uid, name: name, email: email);
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapError(e.code)));
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
