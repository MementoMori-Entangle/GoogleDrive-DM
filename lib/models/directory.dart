class DirectoryInfo {
  final String id;
  final String name;

  DirectoryInfo({required this.id, required this.name});

  factory DirectoryInfo.fromJson(Map<String, dynamic> json) {
    return DirectoryInfo(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectoryInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'DirectoryInfo(id: $id, name: $name)';
}
