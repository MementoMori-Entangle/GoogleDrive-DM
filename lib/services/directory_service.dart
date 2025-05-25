import 'package:google_sign_in/google_sign_in.dart';
import '../models/directory.dart';
import '../repositories/directory_repository.dart';
import '../models/directory_history.dart';
import '../repositories/directory_history_repository.dart';

class DirectoryService {
  final DirectoryRepository _repo = DirectoryRepository();
  final DirectoryHistoryRepository _historyRepo = DirectoryHistoryRepository();
  final List<DirectoryInfo> _defaultDirectories = [
    DirectoryInfo(id: 'root', name: 'root'),
  ];

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
    await _repo.saveDirectories(userId, dirs);
  }

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

  Future<void> addOrUpdateDirectory(
      dynamic user, DirectoryInfo directory) async {
    final dirs = await loadDirectories(user);
    final idx = dirs.indexWhere((d) => d.id == directory.id);
    final now = DateTime.now();
    if (idx >= 0) {
      dirs[idx] = directory;
      await _historyRepo.addHistoryEntry(
        DirectoryHistoryEntry(
          action: 'edit',
          id: directory.id,
          name: directory.name,
          timestamp: now,
        ),
      );
    } else {
      dirs.add(directory);
      await _historyRepo.addHistoryEntry(
        DirectoryHistoryEntry(
          action: 'add',
          id: directory.id,
          name: directory.name,
          timestamp: now,
        ),
      );
    }
    await saveDirectories(user, dirs);
  }

  Future<void> removeDirectory(dynamic user, String id) async {
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
