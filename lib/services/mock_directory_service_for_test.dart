import '../models/directory.dart';
import 'package:googledrive_dm/services/directory_service_interface.dart';

// Widgetテスト用モック
class MockDirectoryServiceForTest implements DirectoryServiceInterface {
  static final List<DirectoryInfo> _dummyDirectories = [
    DirectoryInfo(id: 'root', name: 'ルート'),
    DirectoryInfo(id: 'dir1', name: 'フォルダ1'),
    DirectoryInfo(id: 'dir2', name: 'フォルダ2'),
  ];

  @override
  Future<List<DirectoryInfo>> loadDirectories(dynamic user) async {
    return List<DirectoryInfo>.from(_dummyDirectories);
  }

  @override
  Future<List<DirectoryInfo>> fetchDirectories(dynamic user) async {
    return List<DirectoryInfo>.from(_dummyDirectories);
  }

  @override
  Future<void> saveDirectories(dynamic user, List<DirectoryInfo> dirs) async {}

  @override
  Future<void> addOrUpdateDirectory(
      dynamic user, DirectoryInfo directory) async {}

  @override
  Future<void> removeDirectory(dynamic user, String id) async {}
}
