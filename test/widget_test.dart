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
import 'package:googledrive_dm/screens/directory_edit_screen.dart';
import 'package:googledrive_dm/screens/directory_history_screen.dart';
import 'package:googledrive_dm/screens/directory_list_screen.dart';
import 'package:googledrive_dm/services/mock_auth_service.dart';
import 'package:googledrive_dm/services/mock_directory_service.dart';
import 'package:googledrive_dm/services/mock_drive_service.dart';

/*
  Widgetテスト
  前提
  Web版は最新ドライバーを使用する
  初期値テストを行う場合は、clean & pub getを行う

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
    2-6. ログアウトボタン
      2-6-1. ログアウトボタンをタップ
      2-6-2. ログイン画面へ戻ることを確認
    2-7. アプリ終了ボタン(web版非対応)
      2-7-1. アプリ終了ボタンをタップ
      2-7-2. アプリが終了することを確認
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
      5-1-1. ディレクトリIDテキストフィールドが表示されることを確認
      5-1-2. ディレクトリ名称テキストフィールドが表示されることを確認
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('テスト1から2.3まで（Web/モック認証）', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authServiceInterface: MockAuthService(),
      driveServiceInterface: MockDriveService(),
      directoryServiceInterface: MockDirectoryService(),
    ));
    await tester.pumpAndSettle();

    // ログイン画面が表示されていることを確認
    expect(find.byType(MyApp), findsOneWidget);

    // 「Googleでログイン」ボタンをタップ
    final signInButton = find.text('Googleでログイン');
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
  });

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

    // ディレクトリID登録ボタンを探してタップ
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
  });
}
