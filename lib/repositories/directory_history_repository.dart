import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './directory_history_repository_interface.dart';
import '../models/directory_history.dart';
import '../app_config.dart';

class DirectoryHistoryRepository
    implements DirectoryHistoryRepositoryInterface {
  static const _key = 'directory_history';

  @override
  Future<List<DirectoryHistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list
        .map((e) => DirectoryHistoryEntry.fromJson(jsonDecode(e)))
        .toList();
  }

  @override
  Future<void> saveHistory(List<DirectoryHistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    // 新しい順で最大件数だけ保存
    final limited = entries.take(AppConfig.maxHistoryEntries).toList();
    final list = limited.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  @override
  Future<void> addHistoryEntry(DirectoryHistoryEntry entry) async {
    final history = await loadHistory();
    final newList = [entry, ...history];
    await saveHistory(newList);
  }
}
