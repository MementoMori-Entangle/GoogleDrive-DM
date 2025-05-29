// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:googledrive_dm/app.dart';
import 'package:googledrive_dm/models/directory.dart';
import 'package:googledrive_dm/screens/main_screen.dart';
import 'package:googledrive_dm/screens/directory_edit_screen.dart';
import 'package:googledrive_dm/screens/directory_history_screen.dart';
import 'package:googledrive_dm/screens/directory_list_screen.dart';
import 'package:googledrive_dm/services/mock_auth_service.dart';
import 'package:googledrive_dm/services/mock_directory_service.dart';
import 'package:googledrive_dm/services/mock_drive_service.dart';

/*
  integrationテスト(E2E)
  前提
  Web版は最新ドライバーを使用する
  注意) 登録・修正・削除(各履歴)に関連するテストは
        skip: isAddModDelSkipでセットにすること

  1. ログイン画面
    1-1. Google認証テスト(モック認証)
      1-1-1. Googleでログインボタンをタップ
      1-1-2. メイン(Google Drive Directory Manager)画面へ遷移
  2. メイン画面
    2-1. 初期表示
      2-1-1. ユーザー名とメールアドレスが表示されることを確認
    2-2. ディレクトリ選択ドロップダウン
      2-2-1. 初期状態でrootのみ表示
      2-2-2. rootを選択
      2-2-3. ファイル数と総容量が表示されることを確認
    2-3. Google Drive使用量
      2-3-1. ファイル数と総容量が表示されることを確認
    2-4. 履歴ボタン
      2-4-1. 履歴ボタンをタップ
      2-4-2. ディレクトリ操作履歴画面へ遷移することを確認
    2-5. ディレクトリ一覧ボタン
      2-5-1. ディレクトリ一覧ボタンをタップ
      2-5-2. ディレクトリID一覧画面へ遷移することを確認
    2-6. ディレクトリ追加後のディレクトリ選択ドロップダウン
	    2-6-1. 追加されたディレクトリ情報を確認
    2-7. ログアウトボタン
      2-7-1. ログアウトボタンをタップ
      2-7-2. ログイン画面へ戻ることを確認
    2-8. アプリ終了ボタン(web版非対応)
      2-8-1. アプリ終了ボタンをタップ
      2-8-2. アプリが終了することを確認
  3. ディレクトリ操作履歴画面
    3-1. 初期履歴表示
      3-1-1. 履歴がないことを確認
    3-2. ディレクトリ操作履歴の表示(登録・修正・削除毎に確認)
      3-2-1. ディレクトリ操作履歴が表示されることを確認
      3-2-2. 履歴の内容が正しいことを確認(登録→修正→削除の順で確認)
  4. ディレクトリID一覧画面
    4-1. 初期ディレクトリID一覧の表示
      4-1-1. rootディレクトリのIDが表示されることを確認
    4-2. ディレクトリID一覧の表示
      4-2-1. ディレクトリID一覧が表示されることを確認
      4-2-2. 各ディレクトリのIDが正しいことを確認(登録→修正→削除の順で確認)
    4-3. メイン画面へ戻る
      4-3-1. 戻るボタンをタップ
      4-3-2. メイン画面へ戻ることを確認
  5. ディレクトリID登録画面
    5-1. ディレクトリID登録画面の表示
      5-1-1. ディレクトリIDフォームフィールドが表示されることを確認
      5-1-2. ディレクトリ名称フォームフィールドが表示されることを確認
    5-2. ディレクトリIDの保存
      5-2-1. ディレクトリIDと名称を入力しないで保存ボタンをタップ
        5-2-1-1. ディレクトリIDと名称入力エラーが表示されることを確認
      5-2-2. ディレクトリIDを入力して保存ボタンをタップ
        5-2-2-1. 名称入力エラーが表示されることを確認
      5-2-3. ディレクトリ名称を入力して保存ボタンをタップ
        5-2-3-1. ディレクトリID入力エラーが表示されることを確認
      5-2-4. ディレクトリIDと名称を入力して保存ボタンをタップ
        5-2-4-1. ディレクトリID一覧画面へ遷移し、ディレクトリIDと名称が登録されることを確認
    5-3. ディレクトリID一覧画面へ戻る
      5-3-1. 未入力の状態で戻るボタンをタップ
      5-3-2. ディレクトリID一覧画面へ戻ることを確認
        5-3-2-1. ディレクトリ一覧に変化がないことを確認
      5-3-4. 入力済みの状態で戻るボタンをタップ
        5-3-4-1. ディレクトリID一覧画面へ戻ることを確認
        5-3-4-2. ディレクトリ一覧に変化がないことを確認
  6. ディレクトリID編集画面
    6-1. ディレクトリID編集画面の表示
      6-1-1. ディレクトリIDと名称が表示されることを確認
    6-2. ディレクトリIDの編集
      6-2-1. ディレクトリIDが編集不可であることを確認
      6-2-2. ディレクトリ名称を変更して保存ボタンをタップ
        6-2-2-1. ディレクトリID一覧画面へ遷移し、名称変更内容が反映されることを確認
    6-3. ディレクトリIDの削除
      6-3-1. rootは削除ボタンが表示されないことを確認
      6-3-2. root以外のディレクトリは削除ボタンが表示されることを確認
      6-3-3. 削除ボタンをタップ
        6-3-3-1. 削除確認ダイアログで「削除」をタップ
        6-3-3-2. ディレクトリID一覧画面へ遷移し、削除されたことを確認
    6-4. ディレクトリID一覧画面へ戻る
      6-4-1. 未入力の状態で戻るボタンをタップ
      6-4-2. ディレクトリID一覧画面へ戻ることを確認
        6-4-2-1. ディレクトリ一覧に変化がないことを確認
      6-4-3. 入力済みの状態で戻るボタンをタップ
        6-4-3-1. ディレクトリID一覧画面へ戻ることを確認
        6-4-3-2. ディレクトリ一覧に変化がないことを確認
*/

final dummyUser = 'mock_user';
final dummyEmail = 'mock@example.com';
String loginLabel = 'Googleでログイン';
const bool isShouldSkip = false; // テストをスキップするかどうか
const bool isAddModDelSkip = false; // 登録・修正・削除(各履歴)のテストをスキップするかどうか
const bool isNonWindowsAppSkip = true; // Windowsネイティブアプリをスキップするかどうか
const bool isNonLinuxAppSkip = true; // Linuxネイティブアプリをスキップするかどうか

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Windowsネイティブアプリをテストする場合、モックのMethodChannelを設定
  if (isShouldSkip && isAddModDelSkip && !isNonWindowsAppSkip ||
      !isNonLinuxAppSkip) {
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

  if (!isNonWindowsAppSkip) {
    loginLabel = 'Googleでログイン（Windowsデスクトップ）';
  } else if (!isNonLinuxAppSkip) {
    loginLabel = 'Googleでログイン（Linuxデスクトップ）';
  } else {
    loginLabel = 'Googleでログイン';
  }

  testWidgets('テスト1から2-3まで（モック認証）', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryService(),
    ));
    await tester.pumpAndSettle();

    // ログイン画面が表示されていることを確認
    expect(find.byType(MyApp), findsOneWidget);

    // 「Googleでログイン」ボタンをタップ
    final signInButton = find.text(loginLabel);
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // メイン画面へ遷移したことを確認
    expect(find.byType(MainScreen), findsOneWidget);

    // 初期表示 ユーザー名とメールアドレスが表示されることを確認
    expect(find.byKey(ValueKey('directoryOperatorText')), findsOneWidget);
    expect(find.byKey(ValueKey('userNameText')), findsOneWidget);
    expect(find.byKey(ValueKey('userEmailText')), findsOneWidget);
    expect(find.text('ディレクトリ操作者'), findsOneWidget);
    expect(find.text('ユーザー: $dummyUser'), findsOneWidget);
    expect(find.text('メール: $dummyEmail'), findsOneWidget);

    // 初期表示 ディレクトリ選択ドロップダウンが表示されることを確認
    expect(find.byKey(ValueKey('dropdown')), findsOneWidget);

    // 初期表示 Google Drive使用量の表示があることを確認
    expect(find.byKey(ValueKey('filesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('totalSizeText')), findsOneWidget);
    expect(find.text('ファイル数: 2'), findsOneWidget);
    expect(find.text('総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalFilesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalSizeText')), findsOneWidget);
    expect(find.text('全ディレクトリ総ファイル数: 2'), findsOneWidget);
    expect(find.text('全ディレクトリ総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('googleDriveUsageText')), findsOneWidget);
    expect(find.text('Google Drive使用量: 0.03 GB / 15.00 GB'), findsOneWidget);

    // 初期表示 履歴ボタンが表示されることを確認
    expect(find.byTooltip('履歴'), findsOneWidget);

    // 初期表示 ディレクトリ一覧ボタンが表示されることを確認
    expect(find.byTooltip('ディレクトリ一覧'), findsOneWidget);

    // 初期表示 ログアウトボタンが表示されることを確認
    expect(find.byTooltip('ログアウト'), findsOneWidget);

    // ディレクトリ選択 (初期はrootのみ)
    final dropdown = find.byKey(const ValueKey('dropdown'));
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    final dropdownItem = find.text('root').last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    // ディレクトリドロップボックス選択後
    // ユーザー名とメールアドレスが表示されることを確認
    expect(find.byKey(ValueKey('directoryOperatorText')), findsOneWidget);
    expect(find.byKey(ValueKey('userNameText')), findsOneWidget);
    expect(find.byKey(ValueKey('userEmailText')), findsOneWidget);
    expect(find.text('ディレクトリ操作者'), findsOneWidget);
    expect(find.text('ユーザー: $dummyUser'), findsOneWidget);
    expect(find.text('メール: $dummyEmail'), findsOneWidget);

    // ディレクトリ選択ドロップダウンが表示されることを確認
    expect(find.byKey(ValueKey('dropdown')), findsOneWidget);

    // Google Drive使用量の表示があることを確認
    expect(find.byKey(ValueKey('filesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('totalSizeText')), findsOneWidget);
    expect(find.text('ファイル数: 2'), findsOneWidget);
    expect(find.text('総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalFilesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalSizeText')), findsOneWidget);
    expect(find.text('全ディレクトリ総ファイル数: 2'), findsOneWidget);
    expect(find.text('全ディレクトリ総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('googleDriveUsageText')), findsOneWidget);
    expect(find.text('Google Drive使用量: 0.03 GB / 15.00 GB'), findsOneWidget);

    // 履歴ボタンが表示されることを確認
    expect(find.byTooltip('履歴'), findsOneWidget);

    // ディレクトリ一覧ボタンが表示されることを確認
    expect(find.byTooltip('ディレクトリ一覧'), findsOneWidget);

    // ログアウトボタンが表示されることを確認
    expect(find.byTooltip('ログアウト'), findsOneWidget);
  }, skip: isShouldSkip);

  testWidgets('テスト2-4,3-1', (WidgetTester tester) async {
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
    await tester.pumpAndSettle();

    // ディレクトリ操作履歴画面へ遷移したことを確認
    expect(find.byType(DirectoryHistoryScreen), findsOneWidget);

    // ディレクトリ操作履歴画面への遷移を確認
    expect(find.byKey(ValueKey('dirOpHisTilteText')), findsOneWidget);
    expect(find.text('ディレクトリ操作履歴'), findsOneWidget);

    // 初期状態で履歴がないことを確認
    expect(find.byKey(ValueKey('noHistoryText')), findsOneWidget);
    expect(find.text('履歴はありません'), findsOneWidget);
  });

  testWidgets('テスト2-5,4-1,4-3', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MainScreen(
        user: dummyUser,
        authServiceInterface: MockAuthService(),
        driveServiceInterface: MockDriveService(),
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // ディレクトリ一覧ボタンを探してタップ
    final directoryListButton = find.byTooltip('ディレクトリ一覧');
    expect(directoryListButton, findsOneWidget);
    await tester.tap(directoryListButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ遷移したことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);

    // ディレクトリID一覧画面への遷移を確認
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // 初期状態でrootディレクトリのIDが表示されることを確認
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);

    // 戻るボタンを探してタップ
    final backButton = find.byTooltip('Back');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // メイン画面へ戻ったことを確認
    expect(find.byType(MainScreen), findsOneWidget);

    // ドロップダウンの初期値がrootであることを確認
    final dropdown = find.byKey(const ValueKey('dropdown'));

    final selectedText = find.descendant(
      of: dropdown,
      matching: find.byType(Text),
    );
    expect(selectedText, findsOneWidget);
    expect((tester.widget(selectedText) as Text).data, 'root');

    // ディレクトリ選択ドロップダウンの値がrootのみであること
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final dropdownWidget = tester.widget<DropdownButton>(dropdown);
    expect(dropdownWidget.items, isNotEmpty);
    expect(dropdownWidget.items!.length, 1);
    expect(dropdownWidget.items!.first.value.name, 'root');
  });

  testWidgets('テスト5-1,5-3-1-5-3-2', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DirectoryListScreen(
        user: dummyUser,
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // ディレクトリ追加ボタンを探してタップ
    final directoryAddButton = find.byTooltip('ディレクトリ追加');
    expect(directoryAddButton, findsOneWidget);
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリID登録画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);

    // ディレクトリID登録画面のタイトルが表示されることを確認
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID登録'), findsOneWidget);

    // ディレクトリID登録テキストフィールドが表示されることを確認
    expect(find.byKey(ValueKey('directoryIdTextField')), findsOneWidget);
    expect(find.text('ディレクトリID'), findsOneWidget);

    // ディレクトリ名称登録テキストフィールドが表示されることを確認
    expect(find.byKey(ValueKey('directoryNameTextField')), findsOneWidget);
    expect(find.text('名称'), findsOneWidget);

    // 保存ボタンが表示されることを確認
    expect(find.byKey(ValueKey('saveButtonText')), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);

    // 削除ボタンが表示されないことを確認
    expect(find.byKey(ValueKey('deleteButtonText')), findsNothing);
    expect(find.text('削除'), findsNothing);

    final backButton = find.byTooltip('Back');

    // 戻るボタンが表示されることを確認
    expect(backButton, findsOneWidget);

    // 戻るボタンをタップ
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);

    // ディレクトリID一覧画面のタイトルが表示されることを確認
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に変化がないことを確認
    final listTiles = find.byType(ListTile);
    expect(listTiles, findsNWidgets(1));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
  }, skip: isShouldSkip);

  testWidgets('テスト5-2-1から5-2-3で4-2(登録・戻る)', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DirectoryListScreen(
        user: dummyUser,
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // ディレクトリ追加ボタンを探してタップ
    final directoryAddButton = find.byTooltip('ディレクトリ追加');
    expect(directoryAddButton, findsOneWidget);
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリID登録画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);

    // ディレクトリIDが空であることを確認
    final directoryIdTextField = find.byKey(ValueKey('directoryIdTextField'));
    final TextFormField directoryIdField = tester.widget(directoryIdTextField);
    expect(directoryIdField.controller!.text, '');

    // ディレクトリ名称が空であることを確認
    final directoryNameTextField =
        find.byKey(ValueKey('directoryNameTextField'));
    final TextFormField directoryNameField =
        tester.widget(directoryNameTextField);
    expect(directoryNameField.controller!.text, '');

    // 戻るボタンを探してタップ
    final backButton = find.byTooltip('Back');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に変化がないことを確認
    final listTiles = find.byType(ListTile);
    expect(listTiles, findsNWidgets(1));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsNothing);
    expect(find.text('ID: test_directory_id'), findsNothing);

    // ディレクトリ追加ボタンを再度タップ
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリID登録画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID登録'), findsOneWidget);

    // ディレクトリIDを入力
    await tester.enterText(directoryIdTextField, 'test_directory_id');
    await tester.pumpAndSettle();

    // ディレクトリIDが入力されていることを確認
    final TextFormField updatedDirectoryIdField =
        tester.widget(directoryIdTextField);
    expect(updatedDirectoryIdField.controller!.text, 'test_directory_id');

    // ディレクトリ名称を空にする
    await tester.enterText(directoryNameTextField, '');
    await tester.pumpAndSettle();

    // ディレクトリ名称が空であることを確認
    final TextFormField updatedDirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(updatedDirectoryNameField.controller!.text, '');

    // 戻るボタンをタップ
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に変化がないことを確認
    expect(find.byType(ListTile), findsNWidgets(1));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsNothing);
    expect(find.text('ID: test_directory_id'), findsNothing);

    // ディレクトリ追加ボタンを再度タップ
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリID登録画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID登録'), findsOneWidget);

    // ディレクトリ名称を入力
    await tester.enterText(directoryNameTextField, 'Test Directory Name');
    await tester.pumpAndSettle();

    // ディレクトリ名称が入力されていることを確認
    final TextFormField updated2DirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(updated2DirectoryNameField.controller!.text, 'Test Directory Name');

    // ディレクトリIDを空にする
    await tester.enterText(directoryNameTextField, '');
    await tester.pumpAndSettle();

    // ディレクトリIDが空であることを確認
    final TextFormField updated2DirectoryIdField =
        tester.widget(directoryIdTextField);
    expect(updated2DirectoryIdField.controller!.text, '');

    // 戻るボタンを再度タップ
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に変化がないことを確認
    expect(find.byType(ListTile), findsNWidgets(1));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsNothing);
    expect(find.text('ID: test_directory_id'), findsNothing);

    // ディレクトリ追加ボタンを再度タップ
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリID登録画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID登録'), findsOneWidget);

    // ディレクトリIDと名称を入力
    await tester.enterText(directoryIdTextField, 'test_directory_id');
    await tester.enterText(directoryNameTextField, 'Test Directory Name');

    // ディレクトリIDと名称が入力されていることを確認
    final TextFormField updated3DirectoryIdField =
        tester.widget(directoryIdTextField);
    expect(updated3DirectoryIdField.controller!.text, 'test_directory_id');
    final TextFormField updated3DirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(updated3DirectoryNameField.controller!.text, 'Test Directory Name');

    // 戻るボタンを再度タップ
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に変化がないことを確認
    expect(find.byType(ListTile), findsNWidgets(1));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsNothing);
    expect(find.text('ID: test_directory_id'), findsNothing);
  }, skip: isShouldSkip);

  testWidgets('テスト5-2-1から5-2-4,4-2(登録)', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DirectoryListScreen(
        user: dummyUser,
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // ディレクトリ追加ボタンを探してタップ
    final directoryAddButton = find.byTooltip('ディレクトリ追加');
    expect(directoryAddButton, findsOneWidget);
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリID登録画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);

    // ディレクトリIDが空であることを確認
    final directoryIdTextField = find.byKey(ValueKey('directoryIdTextField'));
    final TextFormField directoryIdField = tester.widget(directoryIdTextField);
    expect(directoryIdField.controller!.text, '');

    // ディレクトリ名称が空であることを確認
    final directoryNameTextField =
        find.byKey(ValueKey('directoryNameTextField'));
    final TextFormField directoryNameField =
        tester.widget(directoryNameTextField);
    expect(directoryNameField.controller!.text, '');

    // 保存ボタンを探してタップ
    final saveButton = find.byKey(ValueKey('saveButtonText'));
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // ディレクトリIDと名称入力エラーが表示されることを確認
    expect(find.text('IDを入力してください'), findsOneWidget);
    expect(find.text('名称を入力してください'), findsOneWidget);

    // ディレクトリIDを入力
    await tester.enterText(directoryIdTextField, 'test_directory_id');
    await tester.pumpAndSettle();

    // ディレクトリIDが入力されていることを確認
    final TextFormField updatedDirectoryIdField =
        tester.widget(directoryIdTextField);
    expect(updatedDirectoryIdField.controller!.text, 'test_directory_id');

    // ディレクトリ名称を空にする
    await tester.enterText(directoryNameTextField, '');
    await tester.pumpAndSettle();

    // ディレクトリ名称が空であることを確認
    final TextFormField updatedDirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(updatedDirectoryNameField.controller!.text, '');

    // 保存ボタンを再度タップ
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // 名称入力エラーが表示されることを確認
    expect(find.text('名称を入力してください'), findsOneWidget);
    expect(find.text('IDを入力してください'), findsNothing);

    // コントローラーがStateで保持されていることを再現するために再遷移
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(directoryAddButton, findsOneWidget);
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリ名称を入力
    await tester.enterText(directoryNameTextField, 'Test Directory Name');
    await tester.pumpAndSettle();

    // ディレクトリ名称が入力されていることを確認
    final TextFormField updated2DirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(updated2DirectoryNameField.controller!.text, 'Test Directory Name');

    // ディレクトリIDを空にする
    await tester.enterText(directoryIdTextField, '');
    await tester.pumpAndSettle();

    // ディレクトリIDが空であることを確認
    final TextFormField updated2DirectoryIdField =
        tester.widget(directoryIdTextField);
    expect(updated2DirectoryIdField.controller!.text, '');

    // 保存ボタンを再度タップ
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // ディレクトリID入力エラーが表示されることを確認
    expect(find.text('IDを入力してください'), findsOneWidget);
    expect(find.text('名称を入力してください'), findsNothing);

    // コントローラーがStateで保持されていることを再現するために再遷移
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(directoryAddButton, findsOneWidget);
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリIDと名称を入力
    await tester.enterText(directoryIdTextField, 'test_directory_id');
    await tester.enterText(directoryNameTextField, 'Test Directory Name');

    // ディレクトリIDと名称が入力されていることを確認
    final TextFormField updated3DirectoryIdField =
        tester.widget(directoryIdTextField);
    expect(updated3DirectoryIdField.controller!.text, 'test_directory_id');
    final TextFormField updated3DirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(updated3DirectoryNameField.controller!.text, 'Test Directory Name');

    // 保存ボタンを再度タップ
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ遷移したことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリIDと名称が登録されていることを確認
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsOneWidget);
    expect(find.text('ID: test_directory_id'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  }, skip: isAddModDelSkip);

  testWidgets('テスト6-1から6-2,6-4,4-2(修正)', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DirectoryListScreen(
        user: dummyUser,
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // テスト5-2-1から5-2-4,4-2(登録)の続き
    // test_directory_idとTest Directory Nameが登録されている状態
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsOneWidget);
    expect(find.text('ID: test_directory_id'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));

    // 前のテストで追加したデータの編集ツールピックをタップして編集画面へ遷移
    final listTile = find.widgetWithText(ListTile, 'Test Directory Name');
    final editButton = find.descendant(
      of: listTile,
      matching: find.byIcon(Icons.edit),
    );
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // ディレクトリID編集画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID編集'), findsOneWidget);
    expect(find.byKey(ValueKey('directoryIdTextField')), findsOneWidget);
    expect(find.text('ディレクトリID'), findsOneWidget);
    expect(find.byKey(ValueKey('directoryNameTextField')), findsOneWidget);
    expect(find.text('名称'), findsOneWidget);
    expect(find.byKey(ValueKey('saveButtonText')), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.byKey(ValueKey('deleteButtonText')), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    // ディレクトリIDが表示されていることを確認
    final directoryIdTextField = find.byKey(ValueKey('directoryIdTextField'));
    final TextFormField directoryIdField = tester.widget(directoryIdTextField);
    expect(directoryIdField.controller!.text, 'test_directory_id');

    // ディレクトリ名称が表示されていることを確認
    final directoryNameTextField =
        find.byKey(ValueKey('directoryNameTextField'));
    final TextFormField directoryNameField =
        tester.widget(directoryNameTextField);
    expect(directoryNameField.controller!.text, 'Test Directory Name');

    // ディレクトリIDフォームフィールドが編集不可であることを確認
    final editableTextFinder = find.descendant(
      of: directoryIdTextField,
      matching: find.byType(EditableText),
    );
    final EditableText editableText = tester.widget(editableTextFinder);
    expect(editableText.readOnly, isTrue);

    // ディレクトリ名称フォームフィールドが編集可能であることを確認
    final editableTextNameFinder = find.descendant(
      of: directoryNameTextField,
      matching: find.byType(EditableText),
    );
    final EditableText editableTextName = tester.widget(editableTextNameFinder);
    expect(editableTextName.readOnly, isFalse);

    // ディレクトリ名称フォームフィールドに新しい名称を入力
    await tester.enterText(directoryNameTextField, 'Updated Directory Name');
    await tester.pumpAndSettle();

    // ディレクトリ名称が更新されていることを確認
    final TextFormField updatedDirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(
        updatedDirectoryNameField.controller!.text, 'Updated Directory Name');

    // 戻るボタンをタップ
    final backButton = find.byTooltip('Back');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に変化がないことを確認
    final listTiles = find.byType(ListTile);
    expect(listTiles, findsNWidgets(2));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsOneWidget);
    expect(find.text('ID: test_directory_id'), findsOneWidget);

    // 前のテストで追加したデータの編集ツールピックをタップして編集画面へ遷移
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // ディレクトリID編集画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID編集'), findsOneWidget);

    // ディレクトリ名称フォームフィールドを空にする
    await tester.enterText(directoryNameTextField, '');
    await tester.pumpAndSettle();

    // ディレクトリ名称が空であることを確認
    final TextFormField emptyDirectoryNameField =
        tester.widget(directoryNameTextField);
    expect(emptyDirectoryNameField.controller!.text, '');

    // 戻るボタンをタップ
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に変化がないことを確認
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Test Directory Name'), findsOneWidget);
    expect(find.text('ID: test_directory_id'), findsOneWidget);

    // 前のテストで追加したデータの編集ツールピックをタップして編集画面へ遷移
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    final TextFormField directoryIdField2 = tester.widget(directoryIdTextField);
    expect(directoryIdField2.controller!.text, 'test_directory_id');

    // ディレクトリ名称が表示されていることを確認
    final TextFormField directoryNameField2 =
        tester.widget(directoryNameTextField);
    expect(directoryNameField2.controller!.text, 'Test Directory Name');

    // ディレクトリ名称フォームフィールドに新しい名称を入力
    await tester.enterText(directoryNameTextField, 'Updated Directory Name');
    await tester.pumpAndSettle();

    // ディレクトリ名称が更新されていることを確認
    final TextFormField updatedDirectoryNameField2 =
        tester.widget(directoryNameTextField);
    expect(
        updatedDirectoryNameField2.controller!.text, 'Updated Directory Name');

    // 保存ボタンをタップ
    final saveButton = find.byKey(ValueKey('saveButtonText'));
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // ディレクトリID一覧に修正された名称が表示されることを確認
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Updated Directory Name'), findsOneWidget);
    expect(find.text('ID: test_directory_id'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  }, skip: isAddModDelSkip);

  testWidgets('テスト6-3,4-2(削除)', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DirectoryListScreen(
        user: dummyUser,
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // テスト6-1から6-2,6-4,4-2(修正)の続き
    // test_directory_idとUpdated Directory Nameが登録されている状態
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
    expect(find.text('Updated Directory Name'), findsOneWidget);
    expect(find.text('ID: test_directory_id'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));

    // rootディレクトリの編集ツールピックをタップして編集画面へ遷移
    final rootListTile = find.widgetWithText(ListTile, 'root');
    final rootEditButton = find.descendant(
      of: rootListTile,
      matching: find.byIcon(Icons.edit),
    );
    await tester.tap(rootEditButton);
    await tester.pumpAndSettle();

    // ディレクトリID編集画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID編集'), findsOneWidget);

    // rootディレクトリは削除できないため、削除ボタンは表示されないことを確認
    expect(find.byKey(ValueKey('deleteButtonText')), findsNothing);
    expect(find.text('削除'), findsNothing);

    // 戻るボタンを探してタップ
    final backButton = find.byTooltip('Back');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // 前のテストで追加したデータの編集ツールピックをタップして編集画面へ遷移
    final listTile = find.widgetWithText(ListTile, 'Updated Directory Name');
    final editButton = find.descendant(
      of: listTile,
      matching: find.byIcon(Icons.edit),
    );
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // ディレクトリID編集画面へ遷移したことを確認
    expect(find.byType(DirectoryEditScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryProcessTypeText')), findsOneWidget);
    expect(find.text('ディレクトリID編集'), findsOneWidget);

    // ディレクトリIDが表示されていることを確認
    final directoryIdTextField = find.byKey(ValueKey('directoryIdTextField'));
    final TextFormField directoryIdField = tester.widget(directoryIdTextField);
    expect(directoryIdField.controller!.text, 'test_directory_id');

    // ディレクトリ名称が表示されていることを確認
    final directoryNameTextField =
        find.byKey(ValueKey('directoryNameTextField'));
    final TextFormField directoryNameField =
        tester.widget(directoryNameTextField);
    expect(directoryNameField.controller!.text, 'Updated Directory Name');

    // 削除ボタンを探してタップ
    final deleteButton = find.byKey(ValueKey('deleteButtonText'));
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // ディレクトリID一覧画面へ戻ったことを確認
    expect(find.byType(DirectoryListScreen), findsOneWidget);
    expect(find.byKey(ValueKey('directoryListTitleText')), findsOneWidget);
    expect(find.text('ディレクトリID一覧'), findsOneWidget);

    // 削除されたディレクトリのIDが表示されていないことを確認
    expect(find.text('Updated Directory Name'), findsNothing);
    expect(find.text('ID: test_directory_id'), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(1));
    expect(find.text('root'), findsOneWidget);
    expect(find.text('ID: root'), findsOneWidget);
  }, skip: isAddModDelSkip);

  testWidgets('テスト3-2', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MainScreen(
        user: dummyUser,
        authServiceInterface: MockAuthService(),
        driveServiceInterface: MockDriveService(),
        directoryServiceInterface: MockDirectoryService(),
      ),
    ));
    await tester.pumpAndSettle();

    // テスト6-3,4-2(削除)の続き
    // 履歴画面へ遷移
    final historyButton = find.byTooltip('履歴');
    expect(historyButton, findsOneWidget);
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    // 履歴画面へ遷移したことを確認
    expect(find.byType(DirectoryHistoryScreen), findsOneWidget);
    expect(find.byKey(ValueKey('dirOpHisTilteText')), findsOneWidget);
    expect(find.text('ディレクトリ操作履歴'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));

    // トップから削除、修正、追加の順で履歴が表示されることを確認
    final listTiles = find.byType(ListTile);
    expect(listTiles, findsNWidgets(3));

    // アクション名（leading）のTextをKeyで取得
    final deleteAction = find.byKey(ValueKey('historyAction_delete_0'));
    final editAction = find.byKey(ValueKey('historyAction_edit_1'));
    final addAction = find.byKey(ValueKey('historyAction_add_2'));

    expect((tester.widget<Text>(deleteAction).data), '削除');
    expect((tester.widget<Text>(editAction).data), '修正');
    expect((tester.widget<Text>(addAction).data), '追加');

    // タイトルやサブタイトルも同様にKeyで取得して検証
    final deleteTitle =
        find.byKey(ValueKey('historyName_Updated Directory Name_0'));
    final editTitle =
        find.byKey(ValueKey('historyName_Updated Directory Name_1'));
    final addTitle = find.byKey(ValueKey('historyName_Test Directory Name_2'));

    expect((tester.widget<Text>(deleteTitle).data), 'Updated Directory Name');
    expect((tester.widget<Text>(editTitle).data), 'Updated Directory Name');
    expect((tester.widget<Text>(addTitle).data), 'Test Directory Name');

    // サブタイトルも同様にKeyで取得して検証
    final deleteSubtitle =
        find.byKey(ValueKey('historyId_test_directory_id_0'));
    final editSubtitle = find.byKey(ValueKey('historyId_test_directory_id_1'));
    final addSubtitle = find.byKey(ValueKey('historyId_test_directory_id_2'));

    expect((tester.widget<Text>(deleteSubtitle).data),
        contains('ID: test_directory_id'));
    expect((tester.widget<Text>(editSubtitle).data),
        contains('ID: test_directory_id'));
    expect((tester.widget<Text>(addSubtitle).data),
        contains('ID: test_directory_id'));
  }, skip: isAddModDelSkip);

  testWidgets('テスト2-6', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryService(),
    ));
    await tester.pumpAndSettle();

    // ログイン画面が表示されていることを確認
    expect(find.byType(MyApp), findsOneWidget);

    // 「Googleでログイン」ボタンをタップ
    final signInButton = find.text(loginLabel);
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // メイン画面へ遷移したことを確認
    expect(find.byType(MainScreen), findsOneWidget);

    // 初期表示 ユーザー名とメールアドレスが表示されることを確認
    expect(find.byKey(ValueKey('directoryOperatorText')), findsOneWidget);
    expect(find.byKey(ValueKey('userNameText')), findsOneWidget);
    expect(find.byKey(ValueKey('userEmailText')), findsOneWidget);
    expect(find.text('ディレクトリ操作者'), findsOneWidget);
    expect(find.text('ユーザー: $dummyUser'), findsOneWidget);
    expect(find.text('メール: $dummyEmail'), findsOneWidget);

    // 初期表示 ディレクトリ選択ドロップダウンが表示されることを確認
    expect(find.byKey(ValueKey('dropdown')), findsOneWidget);

    // 初期表示 Google Drive使用量の表示があることを確認
    expect(find.byKey(ValueKey('filesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('totalSizeText')), findsOneWidget);
    expect(find.text('ファイル数: 2'), findsOneWidget);
    expect(find.text('総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalFilesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalSizeText')), findsOneWidget);
    expect(find.text('全ディレクトリ総ファイル数: 2'), findsOneWidget);
    expect(find.text('全ディレクトリ総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('googleDriveUsageText')), findsOneWidget);
    expect(find.text('Google Drive使用量: 0.03 GB / 15.00 GB'), findsOneWidget);

    // ディレクトリID一覧画面へ遷移
    final directoryListButton = find.byTooltip('ディレクトリ一覧');
    expect(directoryListButton, findsOneWidget);
    await tester.tap(directoryListButton);
    await tester.pumpAndSettle();

    // ディレクトリ追加ボタンを探してタップ
    final directoryAddButton = find.byTooltip('ディレクトリ追加');
    expect(directoryAddButton, findsOneWidget);
    await tester.tap(directoryAddButton);
    await tester.pumpAndSettle();

    // ディレクトリ名称が空であることを確認
    final directoryIdTextField = find.byKey(ValueKey('directoryIdTextField'));
    final directoryNameTextField =
        find.byKey(ValueKey('directoryNameTextField'));

    // ディレクトリIDと名称を入力
    await tester.enterText(directoryIdTextField, 'test_directory_id');
    await tester.enterText(directoryNameTextField, 'Test Directory Name');

    // 保存ボタンを探してタップ
    final saveButton = find.byKey(ValueKey('saveButtonText'));
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // 戻るボタンを探してタップ
    final backButton = find.byTooltip('Back');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // メイン画面へ戻ったことを確認
    expect(find.byType(MainScreen), findsOneWidget);

    // ディレクトリ選択ドロップダウンの値が追加されていることを確認
    final dropdown = find.byKey(ValueKey('dropdown'));
    expect(dropdown, findsOneWidget);

    final dropdownWidget =
        tester.widget<DropdownButton<DirectoryInfo>>(dropdown);
    expect(dropdownWidget.items, isNotNull);
    expect(dropdownWidget.items!.length, 2); // rootと追加したディレクトリID
    expect(dropdownWidget.items![0].value?.id, 'root');
    expect(dropdownWidget.items![0].value?.name, 'root'); // or
    expect(dropdownWidget.items![0].child,
        isA<Text>().having((t) => t.data, 'text', 'root'));

    expect(dropdownWidget.items![1].value?.id, 'test_directory_id');
    expect(dropdownWidget.items![1].value?.name, 'Test Directory Name'); // or
    expect(dropdownWidget.items![1].child,
        isA<Text>().having((t) => t.data, 'text', 'Test Directory Name'));

    // ファイル数と総容量の表示があることを確認
    expect(find.byKey(ValueKey('filesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('totalSizeText')), findsOneWidget);
    expect(find.text('ファイル数: 2'), findsOneWidget);
    expect(find.text('総容量: 2.93 MB'), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalFilesCountText')), findsOneWidget);
    expect(find.byKey(ValueKey('allDirTotalSizeText')), findsOneWidget);
    expect(find.text('全ディレクトリ総ファイル数: 4'), findsOneWidget); // ディレクトリ追加後は初期の倍
    expect(find.text('全ディレクトリ総容量: 5.86 MB'), findsOneWidget); // ディレクトリ追加後は初期の倍
    expect(find.byKey(ValueKey('googleDriveUsageText')), findsOneWidget);
    expect(find.text('Google Drive使用量: 0.03 GB / 15.00 GB'), findsOneWidget);
  }, skip: isShouldSkip);

  testWidgets('テスト2-7', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryService(),
    ));
    await tester.pumpAndSettle();

    // ログイン画面が表示されていることを確認
    expect(find.byType(MyApp), findsOneWidget);

    // 「Googleでログイン」ボタンをタップ
    final signInButton = find.text(loginLabel);
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // メイン画面へ遷移したことを確認
    expect(find.byType(MainScreen), findsOneWidget);

    // ログアウトをタップ
    final logoutButton = find.byTooltip('ログアウト');
    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // ログイン画面へ戻ったことを確認
    expect(find.byType(MyApp), findsOneWidget);

    // 「Googleでログイン」ボタンが表示されていることを確認
    expect(find.text('Googleでログイン'), findsOneWidget);
  }, skip: isShouldSkip);

  testWidgets('テスト2-8(Windows版)', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryService(),
    ));
    await tester.pumpAndSettle();

    // ログイン画面が表示されていることを確認
    expect(find.byType(MyApp), findsOneWidget);

    // 「Googleでログイン」ボタンをタップ
    final signInButton = find.text(loginLabel);
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pump(const Duration(milliseconds: 100));

    // メイン画面へ遷移したことを確認
    expect(find.byType(MainScreen), findsOneWidget);

    // アプリ終了ボタンをタップ
    final exitButton = find.byTooltip('アプリ終了');
    expect(exitButton, findsOneWidget);
    await tester.tap(exitButton);
    print('終了ボタンをタップ');
    await tester.pump(const Duration(milliseconds: 100));
    print('テスト正常終了');
  }, skip: isNonWindowsAppSkip);
}
