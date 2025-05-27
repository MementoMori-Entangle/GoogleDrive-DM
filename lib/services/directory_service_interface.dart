import '../models/directory.dart';

abstract class DirectoryServiceInterface {
  // ユーザーのディレクトリ情報をロードする
  Future<List<DirectoryInfo>> loadDirectories(dynamic user);
  // ユーザーのディレクトリ情報を保存する
  Future<void> saveDirectories(dynamic user, List<DirectoryInfo> dirs);
  // ユーザーのディレクトリ一覧をロードする
  Future<List<DirectoryInfo>> fetchDirectories(dynamic user);
  // ユーザーのディレクトリ情報を追加または更新する
  Future<void> addOrUpdateDirectory(dynamic user, DirectoryInfo directory);
  // ユーザーのディレクトリ情報を指定IDで削除する
  Future<void> removeDirectory(dynamic user, String id);
}
