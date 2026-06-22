import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../features/games/data/datasources/market_questions_datasource.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn {
    // Avoid initializing GoogleSignIn on web without proper client ID config
    if (kIsWeb) {
      return GoogleSignIn(clientId: '');
    }
    return GoogleSignIn();
  }

  @lazySingleton
  MarketQuestionsDatasource get marketQuestionsDatasource =>
      MarketQuestionsDatasourceImpl();
}
