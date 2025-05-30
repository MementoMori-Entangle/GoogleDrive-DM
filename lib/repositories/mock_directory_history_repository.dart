import './directory_history_repository_interface.dart';
import '../models/directory_history.dart';

class MockDirectoryHistoryRepository
    implements DirectoryHistoryRepositoryInterface {
  final List<DirectoryHistoryEntry> _history;

  // 初期値を指定できるコンストラクタ
  MockDirectoryHistoryRepository({List<DirectoryHistoryEntry>? initialHistory})
      : _history = initialHistory ?? [];

  @override
  Future<List<DirectoryHistoryEntry>> loadHistory() async {
    // 現在の履歴リストを返す
    return List.unmodifiable(_history);
  }

  @override
  Future<void> saveHistory(List<DirectoryHistoryEntry> history) async {
    // 履歴を保存（テスト用: コピーして保存）
    _history
      ..clear()
      ..addAll(history);
  }

  @override
  Future<void> addHistoryEntry(DirectoryHistoryEntry entry) async {
    _history.add(entry);
  }
}
