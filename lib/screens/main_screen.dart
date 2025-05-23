import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/drive_service.dart';
import '../services/directory_service.dart';
import '../models/directory.dart';
import 'directory_list_screen.dart';
import 'directory_history_screen.dart';
import 'login_screen.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? fileCount;
  int? totalSize;
  int? allDirectoriesTotalSize;
  int? allDirectoriesTotalFileCount;
  int? driveUsage;
  int? driveLimit;
  bool isLoading = true;
  String? error;
  late List<DirectoryInfo> directories;
  late DirectoryInfo selectedDirectory;
  bool directoriesLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDirectoriesAndInit();
    fetchDriveStorageInfo();
  }

  Future<void> fetchDirectoriesAndInit() async {
    setState(() {
      directoriesLoading = true;
    });
    try {
      directories = await DirectoryService().fetchDirectories(widget.user);
      selectedDirectory = directories.first;
      directoriesLoading = false;
      setState(() {});
      fetchDriveInfo();
      fetchAllDirectoriesTotalSizeAndCount();
    } catch (e) {
      setState(() {
        error = 'ディレクトリ一覧取得エラー: $e';
        directoriesLoading = false;
      });
    }
  }

  Future<void> fetchDriveInfo() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final files = await DriveService().fetchFilesInDirectory(
        user: widget.user,
        directoryId: selectedDirectory.id,
      );
      setState(() {
        fileCount = files.length;
        totalSize = files.fold<int>(0, (sum, f) => sum + f.size);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Google Drive取得エラー: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchAllDirectoriesTotalSizeAndCount() async {
    int sumSize = 0;
    int sumCount = 0;
    for (final dir in directories) {
      try {
        final files = await DriveService().fetchFilesInDirectory(
          user: widget.user,
          directoryId: dir.id,
        );
        sumSize += files.fold<int>(0, (s, f) => s + f.size);
        sumCount += files.length;
      } catch (_) {}
    }
    setState(() {
      allDirectoriesTotalSize = sumSize;
      allDirectoriesTotalFileCount = sumCount;
    });
  }

  Future<void> fetchDriveStorageInfo() async {
    try {
      final info =
          await DriveService().fetchDriveStorageInfo(user: widget.user);
      setState(() {
        driveUsage = info['usage'];
        driveLimit = info['limit'];
      });
    } catch (_) {
      setState(() {
        driveUsage = null;
        driveLimit = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Google Drive', style: TextStyle(fontSize: 18)),
            Text('Directory Manager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'アプリ終了',
            onPressed: () {
              // アプリ終了（Android: SystemNavigator.pop, その他: exit(0)）
              try {
                SystemNavigator.pop();
              } catch (_) {
                exit(0);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              await widget.user.clearAuthCache();
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '履歴',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DirectoryHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'ディレクトリ一覧',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectoryListScreen(user: widget.user),
                ),
              );
              await fetchDirectoriesAndInit();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: directoriesLoading
                ? const CircularProgressIndicator()
                : isLoading
                    ? const CircularProgressIndicator()
                    : error != null
                        ? Text(error!,
                            style: const TextStyle(color: Colors.red))
                        : Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.85 * 255).toInt()),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('ログイン成功！'),
                                Text(
                                    'ユーザー: ${widget.user.displayName ?? "No Name"}'),
                                Text('メール: ${widget.user.email}'),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: DropdownButton<DirectoryInfo>(
                                    value: selectedDirectory,
                                    items: directories
                                        .map((dir) => DropdownMenuItem(
                                              value: dir,
                                              child: Text(dir.name),
                                            ))
                                        .toList(),
                                    onChanged: (dir) {
                                      if (dir != null) {
                                        setState(() {
                                          selectedDirectory = dir;
                                        });
                                        fetchDriveInfo();
                                      }
                                    },
                                    underline: const SizedBox(),
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('ファイル数: ${fileCount ?? "-"}'),
                                Text(
                                    totalSize != null
                                        ? '総容量: ${(totalSize! / (1024 * 1024)).toStringAsFixed(2)} MB'
                                        : '総容量: -'),
                                const SizedBox(height: 8),
                                Text(
                                    '全ディレクトリ総ファイル数: '
                                    '${allDirectoriesTotalFileCount ?? "-"}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    allDirectoriesTotalSize != null
                                        ? '全ディレクトリ総容量: ${(allDirectoriesTotalSize! / (1024 * 1024)).toStringAsFixed(2)} MB'
                                        : '全ディレクトリ総容量: -',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                if (driveUsage != null && driveLimit != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Google Drive使用量: '
                                      '${(driveUsage! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB / '
                                      '${(driveLimit! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                  ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
