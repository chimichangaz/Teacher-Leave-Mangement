class Teacher {
  final String id;
  final String name;
  final String email;
  final int totalLeaves;
  final int usedLeaves;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.totalLeaves,
    required this.usedLeaves,
  });

  factory Teacher.fromMap(Map<String, dynamic> data) {
    return Teacher(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      totalLeaves: data['totalLeaves'] ?? 20,
      usedLeaves: data['usedLeaves'] ?? 0,
    );
  }
}
