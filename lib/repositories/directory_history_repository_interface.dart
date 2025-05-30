import '../models/directory_history.dart';

abstract class DirectoryHistoryRepositoryInterface {
  Future<List<DirectoryHistoryEntry>> loadHistory();
  Future<void> saveHistory(List<DirectoryHistoryEntry> history);
  Future<void> addHistoryEntry(DirectoryHistoryEntry entry);
}
