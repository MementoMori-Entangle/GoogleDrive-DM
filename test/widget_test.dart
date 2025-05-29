// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googledrive_dm/app.dart';
import 'package:googledrive_dm/services/mock_auth_service.dart';
import 'package:googledrive_dm/services/mock_directory_service.dart';
import 'package:googledrive_dm/services/mock_drive_service.dart';

/*
  widgetテスト
*/

final dummyUser = 'mock_user';
final dummyEmail = 'mock@example.com';
String loginLabel = 'Googleでログイン';
const bool isShouldSkip = false; // テストをスキップするかどうか
const bool isNonWindowsAppSkip = true; // Windowsネイティブアプリをスキップするかどうか
const bool isNonLinuxAppSkip = true; // Linuxネイティブアプリをスキップするかどうか

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Windowsネイティブアプリをテストする場合、モックのMethodChannelを設定
  if (isShouldSkip && !isNonWindowsAppSkip || !isNonLinuxAppSkip) {
    const channel = MethodChannel('flutter/windowsize');

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        // 何もせずに成功したことにする
        return null;
      });
    });
  }

  testWidgets('ログイン画面', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryService(),
    ));
  }, skip: isShouldSkip);
}
