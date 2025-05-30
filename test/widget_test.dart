// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googledrive_dm/app.dart';
import 'package:googledrive_dm/models/directory.dart';
import 'package:googledrive_dm/models/directory_history.dart';
import 'package:googledrive_dm/repositories/mock_directory_history_repository.dart';
import 'package:googledrive_dm/screens/directory_edit_screen.dart';
import 'package:googledrive_dm/screens/directory_history_screen.dart';
import 'package:googledrive_dm/screens/directory_list_screen.dart';
import 'package:googledrive_dm/screens/main_screen.dart';
import 'package:googledrive_dm/services/mock_auth_service.dart';
import 'package:googledrive_dm/services/mock_directory_service_for_test.dart';
import 'package:googledrive_dm/services/mock_drive_service.dart';

/*
  widgetテスト
*/
final dummyUser = 'mock_user';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ログイン画面のUIとボタン表示', (tester) async {
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryServiceForTest(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Google Drive Directory Manager'), findsOneWidget);
    expect(find.textContaining('Googleでログイン'), findsOneWidget);
  });

  testWidgets('MainScreenのUIとディレクトリ選択', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MainScreen(
        user: dummyUser,
        authServiceInterface: MockAuthService(),
        driveServiceInterface: MockDriveService(),
        directoryServiceInterface: MockDirectoryServiceForTest(),
        imageProvider:
            const AssetImage('assets/images/test_bg.png'), // テスト用ダミー画像
      ),
    ));
    await tester.pumpAndSettle();

    // タイトルテキストが表示されているか
    expect(find.byKey(const ValueKey('directoryOperatorText')), findsOneWidget);

    // ユーザー名テキストが表示されているか
    expect(find.byKey(const ValueKey('userNameText')), findsOneWidget);

    // メールアドレスが表示されているか
    expect(find.byKey(const ValueKey('userEmailText')), findsOneWidget);

    // ドロップダウンが存在するか
    expect(find.byKey(const ValueKey('dropdown')), findsOneWidget);

    // ドロップダウンの初期値が正しいか
    expect(find.text('ルート'), findsOneWidget);

    // ドロップダウンをタップして展開
    await tester.tap(find.byKey(const ValueKey('dropdown')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ドロップダウンのアイテムが表示されているか
    expect(find.text('フォルダ1'), findsOneWidget);
    expect(find.text('フォルダ2'), findsOneWidget);

    // ドロップダウンから「フォルダ1」を選択
    await tester.tap(find.text('フォルダ1').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 選択後のドロップダウンの値が「フォルダ1」になっているか
    expect(find.text('フォルダ1'), findsOneWidget);

    // Google Drive使用量の表示があることを確認
    expect(find.byKey(ValueKey('filesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('totalSizeText')), findsOneWidget);
    expect(find.text('ファイル数: 2'), findsOneWidget);
    expect(find.text('総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalFilesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalSizeText')), findsOneWidget);
    expect(find.text('全ディレクトリ総ファイル数: 6'), findsOneWidget);
    expect(find.text('全ディレクトリ総容量: 8.79 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('googleDriveUsageText')), findsOneWidget);
    expect(find.text('Google Drive使用量: 0.03 GB / 15.00 GB'), findsOneWidget);

    // ログアウトボタンが表示されることを確認
    expect(find.byTooltip('ログアウト'), findsOneWidget);

    // 履歴ボタンが表示されることを確認
    expect(find.byTooltip('履歴'), findsOneWidget);

    // ディレクトリ一覧ボタンが表示されることを確認
    expect(find.byTooltip('ディレクトリ一覧'), findsOneWidget);
  });

  testWidgets('DirectoryListScreenの一覧表示', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DirectoryListScreen(
        user: dummyUser,
        directoryServiceInterface: MockDirectoryServiceForTest(),
      ),
    ));
    await tester.pumpAndSettle();

    // タイトルテキストが表示されているか
    expect(
        find.byKey(const ValueKey('directoryListTitleText')), findsOneWidget);

    // ダミーディレクトリ名がリストに表示されているか
    expect(find.text('ルート'), findsOneWidget);
    expect(find.text('フォルダ1'), findsOneWidget);
    expect(find.text('フォルダ2'), findsOneWidget);

    // ListTileが3つ（ダミーデータ分）表示されているか
    expect(find.byType(ListTile), findsNWidgets(3));

    // ディレクトリ追加が表示されることを確認
    expect(find.byTooltip('ディレクトリ追加'), findsOneWidget);

    // ディレクトリ編集が表示されることを確認
    expect(find.byIcon(Icons.edit), findsNWidgets(3));
  });

  testWidgets('DirectoryHistoryScreenの履歴表示', (tester) async {
    final mockRepo = MockDirectoryHistoryRepository();
    await tester.pumpWidget(MaterialApp(
      home: DirectoryHistoryScreen(
        directoryHistoryRepositoryInterface: mockRepo,
      ),
    ));
    await tester.pumpAndSettle();

    // ディレクトリ操作履歴画面のタイトルが表示されているか
    expect(find.byKey(ValueKey('dirOpHisTilteText')), findsOneWidget);
    expect(find.text('ディレクトリ操作履歴'), findsOneWidget);

    // 初期状態で履歴がないことを確認
    expect(find.byKey(ValueKey('noHistoryText')), findsOneWidget);
    expect(find.text('履歴はありません'), findsOneWidget);

    await mockRepo.addHistoryEntry(
      DirectoryHistoryEntry(
        action: 'add',
        id: 'dir1',
        name: 'Test Directory 1',
        timestamp: DateTime.now(),
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: DirectoryHistoryScreen(
        key: UniqueKey(), // 再描画のために新しいキーを使用
        directoryHistoryRepositoryInterface: mockRepo,
      ),
    ));
    await tester.pumpAndSettle();

    // 履歴が追加された後、履歴が表示されることを確認
    expect(find.text('追加'), findsOneWidget);
    expect(find.text('Test Directory 1'), findsOneWidget);
    expect(find.textContaining('ID: dir1'), findsOneWidget);
  });

  testWidgets('DirectoryEditScreenのUI', (tester) async {
    DirectoryInfo? initialDirectory;
    await tester.pumpWidget(MaterialApp(
      home: DirectoryEditScreen(
        initialDirectory: initialDirectory,
        onSave: (_) {},
        onDelete: () {},
      ),
    ));
    await tester.pumpAndSettle();

    // 登録の場合
    expect(find.text('ディレクトリID登録'), findsOneWidget);

    // IDと名前のテキストフィールドが表示されているか
    final directoryIdTextField = find.byKey(ValueKey('directoryIdTextField'));
    final TextFormField directoryIdField = tester.widget(directoryIdTextField);
    expect(directoryIdField.controller!.text, '');

    final directoryNameTextField =
        find.byKey(ValueKey('directoryNameTextField'));
    final TextFormField directoryNameField =
        tester.widget(directoryNameTextField);
    expect(directoryNameField.controller!.text, '');

    // 保存ボタンが表示されることを確認
    expect(find.text('保存'), findsOneWidget);

    // 初期ディレクトリが設定されている場合、編集モードのUIを確認
    initialDirectory = DirectoryInfo(id: 'test_id', name: 'Test Directory');

    await tester.pumpWidget(MaterialApp(
      home: DirectoryEditScreen(
        key: UniqueKey(), // 再描画のために新しいキーを使用
        initialDirectory: initialDirectory,
        onSave: (_) {},
        onDelete: () {},
      ),
    ));
    await tester.pumpAndSettle();

    // 編集の場合
    expect(find.text('ディレクトリID編集'), findsOneWidget);

    final directoryIdTextField2 = find.byKey(ValueKey('directoryIdTextField'));
    final TextFormField updated2DirectoryIdField =
        tester.widget(directoryIdTextField2);
    expect(updated2DirectoryIdField.controller!.text, 'test_id');

    final directoryNameTextField2 =
        find.byKey(ValueKey('directoryNameTextField'));
    final TextFormField updated2DirectoryNameField =
        tester.widget(directoryNameTextField2);
    expect(updated2DirectoryNameField.controller!.text, 'Test Directory');

    // IDフィールドが編集不可になっていることを確認
    expect(updated2DirectoryIdField.enabled, isFalse);

    // 保存ボタンが表示されることを確認
    expect(find.text('保存'), findsOneWidget);

    // 削除ボタンが表示されることを確認
    expect(find.text('削除'), findsOneWidget);

    initialDirectory = DirectoryInfo(id: 'root', name: 'ルート');

    await tester.pumpWidget(MaterialApp(
      home: DirectoryEditScreen(
        key: UniqueKey(), // 再描画のために新しいキーを使用
        initialDirectory: initialDirectory,
        onSave: (_) {},
        onDelete: () {},
      ),
    ));
    await tester.pumpAndSettle();

    final directoryIdTextField3 = find.byKey(ValueKey('directoryIdTextField'));
    final TextFormField updated3DirectoryIdField =
        tester.widget(directoryIdTextField3);
    expect(updated3DirectoryIdField.controller!.text, 'root');

    final directoryNameTextField3 =
        find.byKey(ValueKey('directoryNameTextField'));
    final TextFormField updated3DirectoryNameField =
        tester.widget(directoryNameTextField3);
    expect(updated3DirectoryNameField.controller!.text, 'ルート');

    expect(find.text('削除'), findsNothing);
  });
}
