import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthServiceInterface {
  Future<dynamic> signInWithGoogle();
  Future<void> signOut();

  GoogleSignInAccount? get currentUser;
}
