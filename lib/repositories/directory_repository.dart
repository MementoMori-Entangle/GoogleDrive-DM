import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/directory.dart';

class DirectoryRepository {
  static const _key = 'directory_infos';

  Future<List<DirectoryInfo>> loadDirectories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => DirectoryInfo.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveDirectories(List<DirectoryInfo> directories) async {
    final prefs = await SharedPreferences.getInstance();
    final list = directories.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, list);
  }
}