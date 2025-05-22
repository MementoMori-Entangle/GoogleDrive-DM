import 'package:flutter/material.dart';
import '../services/directory_service.dart';
import '../models/directory.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'directory_edit_screen.dart';

class DirectoryListScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  const DirectoryListScreen({super.key, required this.user});

  @override
  State<DirectoryListScreen> createState() => _DirectoryListScreenState();
}

class _DirectoryListScreenState extends State<DirectoryListScreen> {
  List<DirectoryInfo> directories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDirectories();
  }

  Future<void> fetchDirectories() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      directories = await DirectoryService().fetchDirectories(widget.user);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'ディレクトリ一覧取得エラー: $e';
        isLoading = false;
      });
    }
  }

  void addOrEditDirectory(DirectoryInfo directory) async {
    await DirectoryService().addOrUpdateDirectory(widget.user, directory);
    await fetchDirectories();
  }

  void deleteDirectory(DirectoryInfo directory) async {
    await DirectoryService().removeDirectory(widget.user, directory.id);
    await fetchDirectories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ディレクトリID一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'ディレクトリ追加',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectoryEditScreen(
                    onSave: (dir) => addOrEditDirectory(dir),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
                  itemCount: directories.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final dir = directories[index];
                    return ListTile(
                      title: Text(dir.name),
                      subtitle: Text('ID: ${dir.id}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DirectoryEditScreen(
                                initialDirectory: dir,
                                onSave: (d) => addOrEditDirectory(d),
                                onDelete: () => deleteDirectory(dir),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}