// ディレクトリ操作履歴モデル
class DirectoryHistoryEntry {
  final String action; // 'add', 'edit', 'delete'
  final String id;
  final String name;
  final DateTime timestamp;

  DirectoryHistoryEntry({
    required this.action,
    required this.id,
    required this.name,
    required this.timestamp,
  });

  factory DirectoryHistoryEntry.fromJson(Map<String, dynamic> json) {
    return DirectoryHistoryEntry(
      action: json['action'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'action': action,
        'id': id,
        'name': name,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryHistoryEntry &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          id == other.id &&
          name == other.name &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      action.hashCode ^ id.hashCode ^ name.hashCode ^ timestamp.hashCode;

  @override
  String toString() =>
      'DirectoryHistoryEntry(action: $action, id: $id, name: $name, timestamp: $timestamp)';
}
