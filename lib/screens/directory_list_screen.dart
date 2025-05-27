import 'directory_edit_screen.dart';
import '../models/directory.dart';
import 'package:flutter/material.dart';
import 'package:googledrive_dm/services/directory_service_interface.dart';

class DirectoryListScreen extends StatefulWidget {
  final dynamic user; // GoogleSignInAccountまたはDummyUser
  final DirectoryServiceInterface directoryServiceInterface;
  const DirectoryListScreen(
      {super.key, required this.user, required this.directoryServiceInterface});

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
      directories =
          await widget.directoryServiceInterface.fetchDirectories(widget.user);
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
    await widget.directoryServiceInterface
        .addOrUpdateDirectory(widget.user, directory);
    await fetchDirectories();
  }

  void deleteDirectory(DirectoryInfo directory) async {
    await widget.directoryServiceInterface
        .removeDirectory(widget.user, directory.id);
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
              ? Center(
                  child:
                      Text(error!, style: const TextStyle(color: Colors.red)))
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
