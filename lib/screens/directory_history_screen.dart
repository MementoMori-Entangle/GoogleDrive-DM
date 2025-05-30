import 'package:flutter/material.dart';
import '../models/directory_history.dart';
import 'package:googledrive_dm/repositories/directory_history_repository_interface.dart';

class DirectoryHistoryScreen extends StatefulWidget {
  final DirectoryHistoryRepositoryInterface directoryHistoryRepositoryInterface;
  const DirectoryHistoryScreen(
      {super.key, required this.directoryHistoryRepositoryInterface});

  @override
  State<DirectoryHistoryScreen> createState() => _DirectoryHistoryScreenState();
}

class _DirectoryHistoryScreenState extends State<DirectoryHistoryScreen> {
  List<DirectoryHistoryEntry> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true);
    history = await widget.directoryHistoryRepositoryInterface.loadHistory();
    setState(() => isLoading = false);
  }

  String actionLabel(String action) {
    switch (action) {
      case 'add':
        return '追加';
      case 'edit':
        return '修正';
      case 'delete':
        return '削除';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ディレクトリ操作履歴',
          key: ValueKey('dirOpHisTilteText'),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(
                  child: Text('履歴はありません', key: ValueKey('noHistoryText')))
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ListTile(
                      leading: Text(
                        actionLabel(entry.action),
                        key: ValueKey('historyAction_${entry.action}_$index'),
                      ),
                      title: Text(
                        entry.name,
                        key: ValueKey('historyName_${entry.name}_$index'),
                      ),
                      subtitle: Text(
                        'ID: ${entry.id}\n${entry.timestamp.toLocal()}',
                        key: ValueKey('historyId_${entry.id}_$index'),
                      ),
                    );
                  },
                ),
    );
  }
}
