import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import 'main_screen.dart';
import '../app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        if (!kIsWeb && Platform.isWindows && user is Map<String, dynamic>) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                user: user['client'],
                displayName: user['displayName'],
                email: user['email'],
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(user: user),
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Google認証に失敗しました（ユーザー情報が取得できません）';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'ログインに失敗しました。再度お試しください。';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Webでdart:ioのPlatformは使えないため、kIsWebで分岐
    final isWindows = !kIsWeb && Platform.isWindows;
    final isLinux = !kIsWeb && Platform.isLinux;
    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                  ],
                  CustomButton(
                    label: isWindows
                        ? 'Googleでログイン（Windowsデスクトップ）'
                        : isLinux
                            ? 'Googleでログイン（Linuxデスクトップ）'
                            : 'Googleでログイン',
                    onPressed: _handleSignIn,
                  ),
                  if (isWindows)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Windowsでは外部ブラウザ認証が起動します',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  if (isLinux)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Linuxでは外部ブラウザ認証が起動します',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
