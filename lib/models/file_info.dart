class FileInfo {
  final String id;
  final String name;
  final int size;

  FileInfo({required this.id, required this.name, required this.size});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          size == other.size;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ size.hashCode;

  @override
  String toString() => 'FileInfo(id: $id, name: $name, size: $size)';
}
