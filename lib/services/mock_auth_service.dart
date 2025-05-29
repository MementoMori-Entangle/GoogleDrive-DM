import 'auth_service_interface.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googledrive_dm/test_mock/mock_auth_client.dart';
import 'package:googledrive_dm/test_mock/mock_google_sign_in_account_app.dart';
import 'package:googledrive_dm/test_mock/mock_google_sign_in_account_web.dart';

class MockAuthService implements AuthServiceInterface {
  @override
  Future<dynamic> signInWithGoogle() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        return MockGoogleSignInAccountWeb();
      } catch (e) {
        throw Exception('Google認証に失敗しました: $e');
      }
    } else if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      // Windows/Linux用OAuth2.0フロー
      return Future.value(_signInWithGoogleApp());
    } else {
      throw UnimplementedError('このプラットフォームは未対応です');
    }
  }

  @override
  Future<void> signOut() async {
    // モックはなにもしない
  }

  @override
  GoogleSignInAccount? get currentUser => MockGoogleSignInAccountWeb();

  // --- Windows/Linux用OAuth2.0認証フロー実装 ---
  Future<Map<String, dynamic>?> _signInWithGoogleApp() async {
    MockGoogleSignInAccountApp account = MockGoogleSignInAccountApp();
    MockAuthClient client = MockAuthClient();
    String? displayName = account.displayName;
    String email = account.email;

    return {
      'client': client,
      'displayName': (displayName != null && displayName.trim().isNotEmpty)
          ? displayName
          : 'APPユーザー',
      'email': email,
    };
  }
}
