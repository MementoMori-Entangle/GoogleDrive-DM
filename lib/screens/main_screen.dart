import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_size/window_size.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/directory_service.dart';
import '../models/directory.dart';
import 'directory_list_screen.dart';
import 'directory_history_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/drive_service.dart';
import '../app_config.dart';
import 'dart:io' show exit, Platform;
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  final dynamic user; // GoogleSignInAccountまたはDummyUser
  final String? displayName; // Windows用
  final String? email; // Windows用
  const MainScreen({
    super.key,
    required this.user,
    this.displayName,
    this.email,
  });

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
    // Windows/Linuxデスクトップのみウィンドウサイズ変更
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      _setDesktopWindowSize();
    }
    fetchDirectoriesAndInit();
    fetchDriveStorageInfo();
  }

  void _setDesktopWindowSize() {
    if (Platform.isWindows) {
      setWindowTitle(AppConfig.appName);
      setWindowFrame(const Rect.fromLTWH(
        AppConfig.windowLeft,
        AppConfig.windowTop,
        AppConfig.windowWidth,
        AppConfig.windowHeight,
      ));
      setWindowMinSize(
          const Size(AppConfig.windowMinWidth, AppConfig.windowMinHeight));
      setWindowMaxSize(
          const Size(AppConfig.windowMaxWidth, AppConfig.windowMaxHeight));
    } else if (Platform.isLinux) {
      setWindowTitle(AppConfig.appName);
      setWindowFrame(const Rect.fromLTWH(
        AppConfig.windowLeftLinux,
        AppConfig.windowTopLinux,
        AppConfig.windowWidthLinux,
        AppConfig.windowHeightLinux,
      ));
      setWindowMinSize(const Size(
          AppConfig.windowMinWidthLinux, AppConfig.windowMinHeightLinux));
      setWindowMaxSize(const Size(
          AppConfig.windowMaxWidthLinux, AppConfig.windowMaxHeightLinux));
    }
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

  String get userDisplayName {
    if (widget.user is GoogleSignInAccount) {
      return widget.user.displayName ?? 'No Name';
    } else if (widget.displayName != null) {
      return widget.displayName!;
    } else {
      return 'No Name';
    }
  }

  String get userEmail {
    if (widget.user is GoogleSignInAccount) {
      return widget.user.email ?? '';
    } else if (widget.email != null) {
      return widget.email!;
    } else {
      return '';
    }
  }

  Widget _buildCloseButton() {
    if (kIsWeb) return Container();
    // IconButton自体はconstにできない（onPressedが非constクロージャのため）
    return IconButton(
      icon: const Icon(Icons.close),
      tooltip: 'アプリ終了',
      onPressed: () {
        // Windows/Linuxデスクトップはexit(0)、それ以外はSystemNavigator.pop()
        try {
          if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
            exit(0);
          } else {
            SystemNavigator.pop();
          }
        } catch (_) {
          // 何もしない（Webや未対応環境）
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConfig.appTitleMain, style: TextStyle(fontSize: 18)),
            Text(AppConfig.appTitleSub,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          _buildCloseButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              // GoogleSignInAccountの場合のみclearAuthCache/signOut
              if (widget.user is GoogleSignInAccount) {
                await widget.user.clearAuthCache();
                await AuthService().signOut();
              }
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
                              color:
                                  Colors.white.withAlpha((0.85 * 255).toInt()),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('ログイン成功！'),
                                Text('ユーザー: $userDisplayName'),
                                Text('メール: $userEmail'),
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
                                Text(totalSize != null
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
