import 'package:flutter/material.dart';
import '../repositories/directory_history_repository.dart';
import '../models/directory_history.dart';

class DirectoryHistoryScreen extends StatefulWidget {
  const DirectoryHistoryScreen({super.key});

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
    history = await DirectoryHistoryRepository().loadHistory();
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
        title: const Text('ディレクトリ操作履歴'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text('履歴はありません'))
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ListTile(
                      leading: Text(actionLabel(entry.action)),
                      title: Text(entry.name),
                      subtitle: Text('ID: ${entry.id}\n${entry.timestamp.toLocal()}'),
                    );
                  },
                ),
    );
  }
}
