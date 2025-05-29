import 'package:flutter/material.dart';
import '../models/directory.dart';

class DirectoryEditScreen extends StatefulWidget {
  final DirectoryInfo? initialDirectory;
  final void Function(DirectoryInfo directory) onSave;
  final void Function()? onDelete;
  const DirectoryEditScreen({
    super.key,
    this.initialDirectory,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<DirectoryEditScreen> createState() => _DirectoryEditScreenState();
}

class _DirectoryEditScreenState extends State<DirectoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _idController =
        TextEditingController(text: widget.initialDirectory?.id ?? '');
    _nameController =
        TextEditingController(text: widget.initialDirectory?.name ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialDirectory == null ? 'ディレクトリID登録' : 'ディレクトリID編集',
          key: ValueKey('directoryProcessTypeText'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ディレクトリID'),
                validator: (v) => v == null || v.isEmpty ? 'IDを入力してください' : null,
                enabled: widget.initialDirectory == null, // 編集時はID変更不可
                key: ValueKey('directoryIdTextField'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '名称'),
                validator: (v) => v == null || v.isEmpty ? '名称を入力してください' : null,
                key: ValueKey('directoryNameTextField'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(DirectoryInfo(
                              id: _idController.text,
                              name: _nameController.text));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        '保存',
                        key: ValueKey('saveButtonText'),
                      )),
                  if (widget.initialDirectory != null &&
                      widget.onDelete != null &&
                      'root' != _idController.text) // rootディレクトリは削除不可
                    ElevatedButton(
                        onPressed: () {
                          widget.onDelete!();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text(
                          '削除',
                          key: ValueKey('deleteButtonText'),
                        )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
