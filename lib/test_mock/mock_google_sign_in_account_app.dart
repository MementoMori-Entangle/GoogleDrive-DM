import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignInAccountApp implements GoogleSignInAccount {
  @override
  String? get displayName => 'mock_user';

  @override
  String get email => 'mock@example.com';

  @override
  String get id => 'mock_id';

  @override
  String? get photoUrl => null;

  @override
  String? get serverAuthCode => null;

  @override
  Future<GoogleSignInAuthentication> get authentication async {
    return MockGoogleSignInAuthentication();
  }

  @override
  Future<Map<String, String>> get authHeaders =>
      Future.value({'Authorization': 'Bearer mock_token'});

  @override
  Future<void> clearAuthCache() async {}
}

class MockGoogleSignInAuthentication implements GoogleSignInAuthentication {
  @override
  String? get accessToken => 'mock_access_token';

  @override
  String? get idToken => 'mock_id_token';

  @override
  String? get serverAuthCode => null;
}
