import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignInAccountWeb implements GoogleSignInAccount {
  @override
  String get displayName => 'mock_user';

  @override
  String get email => 'mock@example.com';

  @override
  String get id => 'mock_id';

  @override
  String? get photoUrl => null;

  @override
  String? get serverAuthCode => null;

  @override
  Future<GoogleSignInAuthentication> get authentication =>
      throw UnimplementedError();

  @override
  Future<Map<String, String>> get authHeaders => throw UnimplementedError();

  @override
  Future<void> clearAuthCache() async {}
}
