import 'package:google_sign_in/google_sign_in.dart';
import '../models/directory.dart';
import '../repositories/directory_repository.dart';
import '../models/directory_history.dart';
import '../repositories/directory_history_repository.dart';

class DirectoryService {
  final DirectoryRepository _repo = DirectoryRepository();
  final DirectoryHistoryRepository _historyRepo = DirectoryHistoryRepository();
  final List<DirectoryInfo> _defaultDirectories = [
    DirectoryInfo(id: '1GOg_E9HkpHSwiu5CjIsDEnUWJdFOQJW6', name: 'test'),
    DirectoryInfo(id: 'root', name: 'root'),
    DirectoryInfo(id: '1KByKJjIPovnKTcVGdi7OXxmEMi-FCnhd', name: '追加ディレクトリ'),
  ];

  Future<List<DirectoryInfo>> loadDirectories() async {
    final dirs = await _repo.loadDirectories();
    if (dirs.isEmpty) {
      await _repo.saveDirectories(_defaultDirectories);
      return List<DirectoryInfo>.from(_defaultDirectories);
    }
    return dirs;
  }

  Future<void> saveDirectories(List<DirectoryInfo> dirs) async {
    await _repo.saveDirectories(dirs);
  }

  Future<List<DirectoryInfo>> fetchDirectories(GoogleSignInAccount user) async {
    final dirs = await loadDirectories();
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

  Future<void> addOrUpdateDirectory(DirectoryInfo directory) async {
    final dirs = await loadDirectories();
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
    await saveDirectories(dirs);
  }

  Future<void> removeDirectory(String id) async {
    final dirs = await loadDirectories();
    final target = dirs.firstWhere((d) => d.id == id, orElse: () => DirectoryInfo(id: id, name: ''));
    dirs.removeWhere((d) => d.id == id);
    await saveDirectories(dirs);
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