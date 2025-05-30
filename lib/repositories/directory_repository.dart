import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/directory.dart';

class DirectoryRepository {
  String _keyForUser(String userId) => 'directory_infos_$userId';

  Future<List<DirectoryInfo>> loadDirectories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyForUser(userId)) ?? [];
    return list.map((e) => DirectoryInfo.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveDirectories(String userId, List<DirectoryInfo> directories) async {
    final prefs = await SharedPreferences.getInstance();
    final list = directories.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyForUser(userId), list);
  }
}