class Record {
  final int id;
  final DateTime createdAt;
  final DateTime lastModified;
  final bool isDeleted;

  Record({
    required this.id,
    required this.createdAt,
    required this.lastModified,
    required this.isDeleted,
  });

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      createdAt: DateTime.parse(map['createdAt']),
      lastModified: DateTime.parse(map['lastModified']),
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
