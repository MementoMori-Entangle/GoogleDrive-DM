import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:async'; // ← 追加
import 'auth_service_interface.dart';
import '../app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:crypto/crypto.dart';

class AuthService implements AuthServiceInterface {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: AppConfig.googleScopes,
    clientId: kIsWeb ? AppConfig.googleClientIdWeb : null,
  );

  @override
  Future<dynamic> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        final account = await _googleSignIn.signIn();
        if (account == null) {
          throw Exception('Google認証がキャンセルされました');
        }
        return account;
      } catch (e) {
        throw Exception('Google認証に失敗しました: $e');
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Android/iOS用google_sign_inフロー
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
        final account = await _googleSignIn.signIn();
        return account;
      } catch (e) {
        rethrow;
      }
    } else if (!kIsWeb && Platform.isWindows) {
      // Windows用OAuth2.0フロー
      return await _signInWithGoogleWindows();
    } else if (!kIsWeb && Platform.isLinux) {
      // Linux用OAuth2.0フロー
      return await _signInWithGoogleLinux();
    } else {
      throw UnimplementedError('このプラットフォームは未対応です');
    }
  }

  @override
  Future<void> signOut() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      await _googleSignIn.signOut();
    }
    // Windowsはトークン破棄等が必要ならここで実装
  }

  @override
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  // --- Windows用OAuth2.0認証フロー実装 ---
  Future<Map<String, dynamic>?> _signInWithGoogleWindows() async {
    // 1. 認証情報（Google Cloud Consoleで取得したデスクトップアプリ用クライアントIDを利用）
    final clientSecret = AppConfig.googleClientSecretWindows;
    const clientId = AppConfig.googleClientIdWindows;
    const redirectPort = AppConfig.windowsRedirectPort;
    final redirectUri = Uri.parse(AppConfig.windowsRedirectUri);
    const scopes = AppConfig.googleScopes;
    // --- PKCE用コードベリファイア・チャレンジ生成 ---
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    // 2. 認証URL生成（PKCEパラメータ追加）
    final authUrl = Uri.https(
      'accounts.google.com',
      '/o/oauth2/v2/auth',
      {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri.toString(),
        'scope': scopes.join(' '),
        'access_type': 'offline',
        'prompt': 'consent',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );
    // 3. ローカルサーバ起動し認可コード受信
    String? code;
    final completer = Completer<String?>();
    late final dynamic server;
    server = await shelf_io.serve(
      (shelf.Request request) async {
        final bodyStr = await request.readAsString();
        code = request.requestedUri.queryParameters['code'];
        if (code == null) {
          final contentType = request.headers['content-type'] ?? '';
          if (contentType.contains('application/x-www-form-urlencoded')) {
            final params = Uri.splitQueryString(bodyStr);
            code = params['code'];
          }
        }
        if (!completer.isCompleted) {
          completer.complete(code);
        }
        Future.delayed(AppConfig.serverCloseDelay, () => server.close());
        if (code != null) {
          return shelf.Response.ok(
              '<html><body>認証が完了しました。アプリに戻ってください。</body></html>',
              headers: const {'content-type': 'text/html'});
        } else {
          return shelf.Response.notFound('認証コードが見つかりません');
        }
      },
      'localhost',
      redirectPort,
    );
    // WindowsでlaunchUrlが失敗した場合のため、例外をcatchしてエラー表示
    try {
      final launched = await launchUrl(authUrl);
      if (!launched) {
        throw Exception('ブラウザの起動に失敗しました。URL: $authUrl');
      }
    } catch (e) {
      throw Exception('ブラウザの起動に失敗しました。$e');
    }
    // コードが来るまで待機
    code = await completer.future; // ← ここで待機
    if (code == null) {
      throw Exception('認証コードの受信に失敗しました');
    }
    // 4. 認可コードをトークンに交換（PKCE: code_verifierを送信）;
    final tokenUri = Uri.parse('https://oauth2.googleapis.com/token');
    final response = await http.post(
      tokenUri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=authorization_code'
          '&code=${Uri.encodeComponent(code!)}'
          '&client_id=${Uri.encodeComponent(clientId)}'
          '&client_secret=${Uri.encodeComponent(clientSecret)}'
          '&code_verifier=${Uri.encodeComponent(codeVerifier)}'
          '&redirect_uri=${Uri.encodeComponent(redirectUri.toString())}',
    );
    if (response.statusCode != 200) {
      throw Exception('トークン取得に失敗しました: ${response.body}');
    }
    final Map<String, dynamic> tokenData =
        Map<String, dynamic>.from(jsonDecode(response.body));
    try {
      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          tokenData['access_token'] as String,
          DateTime.now()
              .toUtc()
              .add(Duration(seconds: tokenData['expires_in'] as int)),
        ),
        tokenData['refresh_token'] as String?,
        scopes,
      );
      final client = auth.authenticatedClient(http.Client(), credentials);
      // --- 追加: userinfo取得 ---
      final userinfoRes = await client
          .get(Uri.parse('https://openidconnect.googleapis.com/v1/userinfo'));
      String? displayName;
      String? email;
      if (userinfoRes.statusCode == 200) {
        final userinfo = jsonDecode(userinfoRes.body);
        displayName = (userinfo['name'] as String?)?.trim();
        email = (userinfo['email'] as String?)?.trim();
        if (displayName == null || displayName.isEmpty) {
          final given = (userinfo['given_name'] as String?)?.trim() ?? '';
          final family = (userinfo['family_name'] as String?)?.trim() ?? '';
          final combined = '$given $family'.trim();
          if (combined.isNotEmpty) {
            displayName = combined;
          }
        }
      }
      // Googleから取得できたdisplayNameがあれば必ずそれを返す
      return {
        'client': client,
        'displayName': (displayName != null && displayName.trim().isNotEmpty)
            ? displayName
            : 'Windowsユーザー',
        'email': email ?? '',
      };
    } catch (e) {
      rethrow;
    }
  }

  // --- Linux用OAuth2.0認証フロー実装 ---
  Future<Map<String, dynamic>?> _signInWithGoogleLinux() async {
    final clientSecret = AppConfig.googleClientSecretLinux;
    const clientId = AppConfig.googleClientIdLinux;
    const redirectPort = AppConfig.linuxRedirectPort;
    final redirectUri = Uri.parse(AppConfig.linuxRedirectUri);
    const scopes = AppConfig.googleScopes;
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final authUrl = Uri.https(
      'accounts.google.com',
      '/o/oauth2/v2/auth',
      {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri.toString(),
        'scope': scopes.join(' '),
        'access_type': 'offline',
        'prompt': 'consent',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );
    String? code;
    final completer = Completer<String?>();
    late final dynamic server;
    server = await shelf_io.serve(
      (shelf.Request request) async {
        final bodyStr = await request.readAsString();
        code = request.requestedUri.queryParameters['code'];
        if (code == null) {
          final contentType = request.headers['content-type'] ?? '';
          if (contentType.contains('application/x-www-form-urlencoded')) {
            final params = Uri.splitQueryString(bodyStr);
            code = params['code'];
          }
        }
        if (!completer.isCompleted) {
          completer.complete(code);
        }
        Future.delayed(AppConfig.serverCloseDelay, () => server.close());
        if (code != null) {
          return shelf.Response.ok(
              '<html><body>認証が完了しました。アプリに戻ってください。</body></html>',
              headers: const {'content-type': 'text/html'});
        } else {
          return shelf.Response.notFound('認証コードが見つかりません');
        }
      },
      'localhost',
      redirectPort,
    );
    try {
      final launched = await launchUrl(authUrl);
      if (!launched) {
        throw Exception('ブラウザの起動に失敗しました。URL: $authUrl');
      }
    } catch (e) {
      throw Exception('ブラウザの起動に失敗しました。$e');
    }
    code = await completer.future;
    if (code == null) {
      throw Exception('認証コードの受信に失敗しました');
    }
    final tokenUri = Uri.parse('https://oauth2.googleapis.com/token');
    final response = await http.post(
      tokenUri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=authorization_code'
          '&code=${Uri.encodeComponent(code!)}'
          '&client_id=${Uri.encodeComponent(clientId)}'
          '&client_secret=${Uri.encodeComponent(clientSecret)}'
          '&code_verifier=${Uri.encodeComponent(codeVerifier)}'
          '&redirect_uri=${Uri.encodeComponent(redirectUri.toString())}',
    );
    if (response.statusCode != 200) {
      throw Exception('トークン取得に失敗しました: ${response.body}');
    }
    final Map<String, dynamic> tokenData =
        Map<String, dynamic>.from(jsonDecode(response.body));
    try {
      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          tokenData['access_token'] as String,
          DateTime.now()
              .toUtc()
              .add(Duration(seconds: tokenData['expires_in'] as int)),
        ),
        tokenData['refresh_token'] as String?,
        scopes,
      );
      final client = auth.authenticatedClient(http.Client(), credentials);
      final userinfoRes = await client
          .get(Uri.parse('https://openidconnect.googleapis.com/v1/userinfo'));
      String? displayName;
      String? email;
      if (userinfoRes.statusCode == 200) {
        final userinfo = jsonDecode(userinfoRes.body);
        displayName = (userinfo['name'] as String?)?.trim();
        email = (userinfo['email'] as String?)?.trim();
        if (displayName == null || displayName.isEmpty) {
          final given = (userinfo['given_name'] as String?)?.trim() ?? '';
          final family = (userinfo['family_name'] as String?)?.trim() ?? '';
          final combined = '$given $family'.trim();
          if (combined.isNotEmpty) {
            displayName = combined;
          }
        }
      }
      return {
        'client': client,
        'displayName': (displayName != null && displayName.trim().isNotEmpty)
            ? displayName
            : 'Linuxユーザー',
        'email': email ?? '',
      };
    } catch (e) {
      rethrow;
    }
  }

  // --- PKCE用ユーティリティ ---
  String _generateCodeVerifier() {
    final rand = List<int>.generate(
        64, (i) => (DateTime.now().microsecondsSinceEpoch + i) % 256);
    return base64UrlEncode(rand)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }
}
