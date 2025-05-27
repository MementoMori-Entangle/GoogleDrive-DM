// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:googledrive_dm/app.dart';
import 'package:googledrive_dm/screens/main_screen.dart';
import 'package:googledrive_dm/services/mock_auth_service.dart';
import 'package:googledrive_dm/services/mock_directory_service.dart';
import 'package:googledrive_dm/services/mock_drive_service.dart';

final dummyUser = 'mock_user';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Google Driveファイル数と容量の取得テスト（Web/モック認証）',
      (WidgetTester tester) async {
    // モックサービスでアプリ起動
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryService(),
    ));
    await tester.pumpAndSettle();

    // 「Googleでログイン」ボタンをタップ
    final signInButton = find.text('Googleでログイン');
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // モック認証後、ファイル数・容量が表示されることを確認
    expect(find.byKey(ValueKey('filesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('totalSizeText')), findsOneWidget);
    // 初期はファイル:2 容量:2.93MB
    expect(find.byKey(ValueKey('allDirTotalFilesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalSizeText')), findsOneWidget);
    //expect(find.textContaining('全ディレクトリ総ファイル数: 4'), findsOneWidget);
    //expect(find.textContaining('全ディレクトリ総容量: 5.86MB'), findsOneWidget);
  });

  testWidgets('履歴ボタンでDirectoryHistoryScreenに遷移する', (WidgetTester tester) async {
    // 必要なモックサービスでMainScreenを起動
    await tester.pumpWidget(MaterialApp(
      home: MainScreen(
        user: dummyUser,
        authServiceInterface: MockAuthService(),
        driveServiceInterface: MockDriveService(),
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // 履歴ボタンを探してタップ
    final historyButton = find.byTooltip('履歴');
    expect(historyButton, findsOneWidget);
    await tester.tap(historyButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));

    // DirectoryHistoryScreenへの遷移を確認
    expect(find.byKey(ValueKey('dirOpHisTilteText')), findsOneWidget);
    //expect(find.text('ディレクトリ操作履歴'), findsOneWidget);
    //expect(find.byKey(ValueKey('historyAction_add_0')), findsOneWidget);
    //expect(find.byKey(ValueKey('historyName_11111_0')), findsOneWidget);
  });
}
