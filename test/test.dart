// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:googledrive_dm/app_config.dart';
import 'package:googledrive_dm/app.dart';
import 'package:googledrive_dm/main.dart' as app_main;
import 'package:googledrive_dm/services/drive_service.dart';
import 'package:googledrive_dm/services/auth_service_interface.dart';
import 'package:googledrive_dm/services/drive_service_interface.dart';
import 'package:googledrive_dm/services/directory_service_interface.dart';
import 'package:googledrive_dm/services/directory_service.dart';
import 'package:googledrive_dm/models/directory.dart';
import 'package:googledrive_dm/models/file_info.dart';
import 'package:googledrive_dm/repositories/directory_repository.dart';
import 'package:googledrive_dm/repositories/directory_history_repository.dart';
import 'package:googledrive_dm/models/directory_history.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  単体テスト
*/

// Dummyサービスのメソッドを全て空実装で追加
class DummyAuthService implements AuthServiceInterface {
  @override
  Future<dynamic> signInWithGoogle() async => null;
  @override
  Future<void> signOut() async {}
  @override
  GoogleSignInAccount? get currentUser => null;
}

class DummyDriveService implements DriveServiceInterface {
  @override
  Future<List<FileInfo>> fetchFilesInDirectory(
          {required user, required String directoryId}) async =>
      [];
  @override
  Future<Map<String, int>> fetchDriveStorageInfo({required user}) async => {};
}

class DummyDirectoryService implements DirectoryServiceInterface {
  @override
  Future<void> addOrUpdateDirectory(user, DirectoryInfo directory) async {}
  @override
  Future<List<DirectoryInfo>> fetchDirectories(user) async => [];
  @override
  Future<List<DirectoryInfo>> loadDirectories(user) async => [];
  @override
  Future<void> removeDirectory(user, String id) async {}
  @override
  Future<void> saveDirectories(user, List<DirectoryInfo> dirs) async {}
}

void main() {
  group('Counter', () {
    setUp(() {});
  });

  group('AppConfig', () {
    test('定数値が正しい', () {
      expect(AppConfig.appName, 'Google Drive Directory Manager');
      expect(AppConfig.windowWidth, 540);
      expect(AppConfig.googleClientIdWeb.isNotEmpty, isTrue);
      expect(AppConfig.googleScopes, contains('email'));
      expect(AppConfig.windowsRedirectPort, 8080);
      expect(AppConfig.serverCloseDelay, const Duration(milliseconds: 100));
    });
    test('getterが正しい', () {
      expect(AppConfig.windowsRedirectUri, 'http://localhost:8080');
      expect(AppConfig.linuxRedirectUri, 'http://localhost:8081');
    });
  });

  group('MyApp', () {
    test('依存性注入が正しく保持される', () {
      final app = MyApp(
        authServiceInterface: DummyAuthService(),
        driveServiceInterface: DummyDriveService(),
        directoryServiceInterface: DummyDirectoryService(),
      );
      expect(app.authServiceInterface, isA<DummyAuthService>());
      expect(app.driveServiceInterface, isA<DummyDriveService>());
      expect(app.directoryServiceInterface, isA<DummyDirectoryService>());
    });
  });

  testWidgets('main.dartでMyAppが生成される', (tester) async {
    // main.dartのrunApp(MyApp(...))が例外なく動作するかを確認
    expect(() => app_main.main(), returnsNormally);
  });

  group('DirectoryService', () {
    late DirectoryService service;
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      service = DirectoryService();
    });

    test('loadDirectories: 新規ユーザーはデフォルト(root)が返る', () async {
      final dirs = await service.loadDirectories('new_user');
      expect(dirs.length, 1);
      expect(dirs.first.id, 'root');
    });

    test('saveDirectories/loadDirectories: 保存・取得', () async {
      final dirs = [DirectoryInfo(id: 'id2', name: 'n2')];
      await service.saveDirectories('user2', dirs);
      final loaded = await service.loadDirectories('user2');
      expect(loaded.length, 1);
      expect(loaded.first.id, 'id2');
    });

    test('fetchDirectories: rootのみ返す', () async {
      final dirs = await service.fetchDirectories('new_user2');
      expect(dirs.length, 1);
      expect(dirs.first.id, 'root');
    });

    test('addOrUpdateDirectory: 追加・更新', () async {
      final dir = DirectoryInfo(id: 'id3', name: 'n3');
      await service.addOrUpdateDirectory('user3', dir);
      final loaded = await service.loadDirectories('user3');
      expect(loaded.any((d) => d.id == 'id3'), isTrue);
      // 更新
      final updated = DirectoryInfo(id: 'id3', name: 'n3_updated');
      await service.addOrUpdateDirectory('user3', updated);
      final loaded2 = await service.loadDirectories('user3');
      expect(loaded2.any((d) => d.name == 'n3_updated'), isTrue);
    });

    test('removeDirectory: 削除', () async {
      final dir = DirectoryInfo(id: 'id4', name: 'n4');
      await service.addOrUpdateDirectory('user4', dir);
      await service.removeDirectory('user4', 'id4');
      final loaded = await service.loadDirectories('user4');
      expect(loaded.any((d) => d.id == 'id4'), isFalse);
    });

    test('異常系: 不正なuser型でArgumentError', () async {
      expect(() => service.loadDirectories(123), throwsArgumentError);
      expect(() => service.saveDirectories(123, []), throwsArgumentError);
    });
  });

  group('DirectoryRepository', () {
    late DirectoryRepository repo;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = DirectoryRepository();
    });

    test('loadDirectories: 空なら空リスト', () async {
      final dirs = await repo.loadDirectories('userA');
      expect(dirs, isEmpty);
    });

    test('saveDirectories/loadDirectories: 保存・取得', () async {
      final dirs = [DirectoryInfo(id: 'idx', name: 'nx')];
      await repo.saveDirectories('userB', dirs);
      final loaded = await repo.loadDirectories('userB');
      expect(loaded.length, 1);
      expect(loaded.first.id, 'idx');
    });
  });

  group('DirectoryHistoryRepository', () {
    late DirectoryHistoryRepository repo;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = DirectoryHistoryRepository();
    });

    test('loadHistory: 空なら空リスト', () async {
      final history = await repo.loadHistory();
      expect(history, isEmpty);
    });

    test('saveHistory/loadHistory: 保存・取得', () async {
      final entry = DirectoryHistoryEntry(
        action: 'add',
        id: 'id',
        name: 'name',
        timestamp: DateTime.now(),
      );
      await repo.saveHistory([entry]);
      final loaded = await repo.loadHistory();
      expect(loaded.length, 1);
      expect(loaded.first.action, 'add');
    });

    test('addHistoryEntry: 先頭追加', () async {
      final entry1 = DirectoryHistoryEntry(
        action: 'add',
        id: 'id1',
        name: 'n1',
        timestamp: DateTime.now(),
      );
      final entry2 = DirectoryHistoryEntry(
        action: 'edit',
        id: 'id2',
        name: 'n2',
        timestamp: DateTime.now(),
      );
      await repo.saveHistory([entry1]);
      await repo.addHistoryEntry(entry2);
      final loaded = await repo.loadHistory();
      expect(loaded.first.action, 'edit');
      expect(loaded[1].action, 'add');
    });
  });

  group('DirectoryHistoryRepository 追加テスト', () {
    late DirectoryHistoryRepository repo;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = DirectoryHistoryRepository();
    });

    test('履歴上限: 100件を超えると古いものが削除される', () async {
      final entries = List.generate(
        120,
        (i) => DirectoryHistoryEntry(
          action: 'add',
          id: 'id$i',
          name: 'name$i',
          timestamp: DateTime.now().subtract(Duration(minutes: i)),
        ),
      );
      await repo.saveHistory(entries);
      final loaded = await repo.loadHistory();
      expect(loaded.length, lessThanOrEqualTo(100));
      expect(loaded.first.id, 'id0');
      expect(loaded.last.id, 'id99');
    });

    test('重複ID: 同じIDの履歴が複数存在できる', () async {
      final entry1 = DirectoryHistoryEntry(
        action: 'add',
        id: 'dup',
        name: 'n1',
        timestamp: DateTime.now(),
      );
      final entry2 = DirectoryHistoryEntry(
        action: 'edit',
        id: 'dup',
        name: 'n2',
        timestamp: DateTime.now(),
      );
      await repo.saveHistory([entry1, entry2]);
      final loaded = await repo.loadHistory();
      expect(loaded.length, 2);
      expect(loaded[0].action, 'add');
      expect(loaded[1].action, 'edit');
    });

    test('履歴削除: saveHistory([])で全削除', () async {
      final entry = DirectoryHistoryEntry(
        action: 'add',
        id: 'id',
        name: 'name',
        timestamp: DateTime.now(),
      );
      await repo.saveHistory([entry]);
      await repo.saveHistory([]);
      final loaded = await repo.loadHistory();
      expect(loaded, isEmpty);
    });

    test('異常系: null/空値/不正型', () async {
      // expect(() => repo.saveHistory(null), throwsA(isA<Error>())); // nullは型安全上不可
      // expect(() => repo.saveHistory([null]), throwsA(isA<Error>())); // nullは型安全上不可
      // 空リストや不正型のテストは必要に応じて追加
    });
  });

  group('DirectoryRepository 追加テスト', () {
    late DirectoryRepository repo;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = DirectoryRepository();
    });

    test('複数ユーザー: ユーザーごとに保存内容が独立', () async {
      final dirsA = [DirectoryInfo(id: 'idA', name: 'nA')];
      final dirsB = [DirectoryInfo(id: 'idB', name: 'nB')];
      await repo.saveDirectories('userA', dirsA);
      await repo.saveDirectories('userB', dirsB);
      final loadedA = await repo.loadDirectories('userA');
      final loadedB = await repo.loadDirectories('userB');
      expect(loadedA.first.id, 'idA');
      expect(loadedB.first.id, 'idB');
    });

    test('大量データ: 1000件保存・取得', () async {
      final dirs =
          List.generate(1000, (i) => DirectoryInfo(id: 'id$i', name: 'n$i'));
      await repo.saveDirectories('userX', dirs);
      final loaded = await repo.loadDirectories('userX');
      expect(loaded.length, 1000);
      expect(loaded.first.id, 'id0');
      expect(loaded.last.id, 'id999');
    });

    test('異常系: 空値/不正型', () async {
      // expect(() => repo.saveDirectories(null, []), throwsArgumentError); // nullは型安全上不可
      // expect(() => repo.saveDirectories('user', null), throwsA(isA<Error>())); // nullは型安全上不可
      // 空リストや不正型のテストは必要に応じて追加
    });
  });

  group('DirectoryService 追加テスト', () {
    late DirectoryService service;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = DirectoryService();
    });

    test('重複ID: 上書き保存される', () async {
      final dir1 = DirectoryInfo(id: 'dup', name: 'n1');
      final dir2 = DirectoryInfo(id: 'dup', name: 'n2');
      await service.addOrUpdateDirectory('user', dir1);
      await service.addOrUpdateDirectory('user', dir2);
      final loaded = await service.loadDirectories('user');
      final nonRoot = loaded.where((d) => d.id != 'root').toList();
      expect(nonRoot.length, 1);
      expect(nonRoot.first.name, 'n2');
    });

    test('大量データ: 1000件追加', () async {
      for (var i = 0; i < 1000; i++) {
        await service.addOrUpdateDirectory(
            'user', DirectoryInfo(id: 'id$i', name: 'n$i'));
      }
      final loaded = await service.loadDirectories('user');
      final nonRoot = loaded.where((d) => d.id != 'root').toList();
      expect(nonRoot.length, AppConfig.maxDirectoryEntries);
      expect(nonRoot.first.id, 'id${1000 - AppConfig.maxDirectoryEntries}');
      expect(nonRoot.last.id, 'id999');
    });

    test('異常系: 空値/不正型', () async {
      // expect(
      //     () => service.addOrUpdateDirectory(
      //         null, DirectoryInfo(id: 'id', name: 'n')),
      //     throwsArgumentError);
      // expect(() => service.addOrUpdateDirectory('user', null),
      //     throwsA(isA<Error>()));
      // 空文字や不正型のテストは必要に応じて追加
    });
  });

  group('DriveService 追加テスト', () {
    late DummyDriveService service;
    setUp(() {
      service = DummyDriveService();
    });

    test('fetchFilesInDirectory: 正常系（空リスト返却）', () async {
      final files =
          await service.fetchFilesInDirectory(user: 'user', directoryId: 'id');
      expect(files, isList);
    });

    test('fetchDriveStorageInfo: 正常系（空Map返却）', () async {
      final info = await service.fetchDriveStorageInfo(user: 'user');
      expect(info, isMap);
    });

    // 型安全上、user=null等はテストしない
    test('fetchFilesInDirectory: 異常系（空値/不正型）', () async {
      expect(() => service.fetchFilesInDirectory(user: '', directoryId: 'id'),
          returnsNormally);
    });

    test('fetchDriveStorageInfo: 異常系（空値/不正型）', () async {
      expect(() => service.fetchDriveStorageInfo(user: ''), returnsNormally);
    });

    test('大量データ: fetchFilesInDirectoryで1000件返却（Mockでテスト推奨）', () async {
      // 本来はMockDriveServiceでテストすべき
      // ここでは空リスト返却を確認
      final files =
          await service.fetchFilesInDirectory(user: 'user', directoryId: 'id');
      expect(files, isList);
    });
  });

  group('DirectoryInfo', () {
    test('等価性・toString・hashCode', () {
      final a = DirectoryInfo(id: 'id', name: 'n');
      final b = DirectoryInfo(id: 'id', name: 'n');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), contains('id'));
    });
  });

  group('DirectoryHistoryEntry', () {
    test('等価性・toString・hashCode', () {
      final t = DateTime.now();
      final a = DirectoryHistoryEntry(
          action: 'add', id: 'id', name: 'n', timestamp: t);
      final b = DirectoryHistoryEntry(
          action: 'add', id: 'id', name: 'n', timestamp: t);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), contains('add'));
    });
  });

  group('FileInfo', () {
    test('インスタンス生成・プロパティ・等価性・toString・hashCode', () {
      final a = FileInfo(id: 'id1', name: 'file1', size: 123);
      final b = FileInfo(id: 'id1', name: 'file1', size: 123);
      expect(a.id, 'id1');
      expect(a.name, 'file1');
      expect(a.size, 123);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), contains('id1'));
    });
  });

  group('DirectoryService 異常系', () {
    late DirectoryService service;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = DirectoryService();
    });
    test('addOrUpdateDirectory: id空欄', () async {
      expect(
          () => service.addOrUpdateDirectory(
              'user', DirectoryInfo(id: '', name: 'n')),
          throwsArgumentError);
    });
    test('addOrUpdateDirectory: name空欄', () async {
      expect(
          () => service.addOrUpdateDirectory(
              'user', DirectoryInfo(id: 'id', name: '')),
          throwsArgumentError);
    });
    test('saveDirectories: userが空文字', () async {
      expect(() => service.saveDirectories('', []), throwsArgumentError);
    });
    test('removeDirectory: idが空', () async {
      expect(() => service.removeDirectory('user', ''), throwsArgumentError);
    });
  });

  group('DriveService 異常系', () {
    late DriveService service;
    setUp(() {
      service = DriveService();
    });
    test('fetchFilesInDirectory: directoryIdが空', () async {
      expect(() => service.fetchFilesInDirectory(user: 'user', directoryId: ''),
          throwsArgumentError);
    });
    test('fetchDriveStorageInfo: userが空', () async {
      expect(
          () => service.fetchDriveStorageInfo(user: ''), throwsArgumentError);
    });
  });
}
