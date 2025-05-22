import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/directory_history.dart';

class DirectoryHistoryRepository {
  static const _key = 'directory_history';

  Future<List<DirectoryHistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => DirectoryHistoryEntry.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveHistory(List<DirectoryHistoryEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  Future<void> addHistoryEntry(DirectoryHistoryEntry entry) async {
    final history = await loadHistory();
    history.insert(0, entry); // 新しい履歴を先頭に
    await saveHistory(history);
  }
}
