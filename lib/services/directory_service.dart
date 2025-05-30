import '../app_config.dart';
import '../models/directory.dart';
import '../repositories/directory_repository.dart';
import '../models/directory_history.dart';
import '../repositories/directory_history_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googledrive_dm/services/directory_service_interface.dart';

class DirectoryService implements DirectoryServiceInterface {
  final DirectoryRepository _repo = DirectoryRepository();
  final DirectoryHistoryRepository _historyRepo = DirectoryHistoryRepository();
  final List<DirectoryInfo> _defaultDirectories = [
    DirectoryInfo(id: 'root', name: 'root'),
  ];

  @override
  Future<List<DirectoryInfo>> loadDirectories(dynamic user) async {
    String userId;
    if (user is String) {
      userId = user;
    } else if (user is GoogleSignInAccount) {
      userId = user.id;
    } else if (user.runtimeType.toString().contains('AuthenticatedClient')) {
      userId = "windows_user";
    } else if (user is Map<String, dynamic>) {
      // LinuxはMap<String, dynamic>で渡されることを想定
      if (user.containsKey('client')) {
        userId = user['email'] ?? user['displayName'] ?? 'linux_user';
      } else {
        userId = 'linux_user';
      }
    } else {
      throw ArgumentError(
          'userはGoogleSignInAccountまたはAuthClientまたはStringである必要があります');
    }
    final dirs = await _repo.loadDirectories(userId);
    if (dirs.isEmpty) {
      await _repo.saveDirectories(userId, _defaultDirectories);
      return List<DirectoryInfo>.from(_defaultDirectories);
    }
    return dirs;
  }

  @override
  Future<void> saveDirectories(dynamic user, List<DirectoryInfo> dirs) async {
    String userId;
    if (user is String) {
      userId = user;
    } else if (user is GoogleSignInAccount) {
      userId = user.id;
    } else if (user.runtimeType.toString().contains('AuthenticatedClient')) {
      userId = "windows_user";
    } else if (user is Map<String, dynamic>) {
      // LinuxはMap<String, dynamic>で渡されることを想定
      if (user.containsKey('client')) {
        userId = user['email'] ?? user['displayName'] ?? 'linux_user';
      } else {
        userId = 'linux_user';
      }
    } else {
      throw ArgumentError(
          'userはGoogleSignInAccountまたはAuthClientまたはStringである必要があります');
    }
    if (userId.isEmpty) {
      throw ArgumentError('userIdは空にできません');
    }
    await _repo.saveDirectories(userId, dirs);
  }

  @override
  Future<List<DirectoryInfo>> fetchDirectories(dynamic user) async {
    final dirs = await loadDirectories(user);
    List<DirectoryInfo> result = [];
    for (final dir in dirs) {
      try {
        if (dir.id == 'root') {
          result.add(dir);
        } else {
          result.add(DirectoryInfo(id: dir.id, name: dir.name));
        }
      } catch (_) {
        result.add(dir);
      }
    }
    return result;
  }

  @override
  Future<void> addOrUpdateDirectory(
      dynamic user, DirectoryInfo directory) async {
    if (directory.id.isEmpty) {
      throw ArgumentError('idは空にできません');
    }
    if (directory.name.isEmpty) {
      throw ArgumentError('nameは空にできません');
    }
    final dirs = await loadDirectories(user);
    final idx = dirs.indexWhere((d) => d.id == directory.id);
    // 追加・更新問わず、同じIDの要素を全て削除
    dirs.removeWhere((d) => d.id == directory.id);
    dirs.add(directory);
    // 最大件数を超える場合は古いものから削除
    final nonRoot = dirs.where((d) => d.id != 'root').toList();
    if (nonRoot.length > AppConfig.maxDirectoryEntries) {
      final keepRoot = dirs.where((d) => d.id == 'root').toList();
      final limit = AppConfig.maxDirectoryEntries;
      final limited = nonRoot.sublist(nonRoot.length - limit.toInt());
      dirs
        ..clear()
        ..addAll(keepRoot)
        ..addAll(limited);
    }
    final now = DateTime.now();
    await _historyRepo.addHistoryEntry(
      DirectoryHistoryEntry(
        action: idx >= 0 ? 'edit' : 'add',
        id: directory.id,
        name: directory.name,
        timestamp: now,
      ),
    );
    await saveDirectories(user, dirs);
  }

  @override
  Future<void> removeDirectory(dynamic user, String id) async {
    if (id.isEmpty) {
      throw ArgumentError('idは空にできません');
    }
    final dirs = await loadDirectories(user);
    final target = dirs.firstWhere((d) => d.id == id,
        orElse: () => DirectoryInfo(id: id, name: ''));
    dirs.removeWhere((d) => d.id == id);
    await saveDirectories(user, dirs);
    await _historyRepo.addHistoryEntry(
      DirectoryHistoryEntry(
        action: 'delete',
        id: target.id,
        name: target.name,
        timestamp: DateTime.now(),
      ),
    );
  }
}
