class Student {
  final int id;
  final String studentId;
  final String name;
  final int sectionId;
  final String gender;
  final String? company;
  final int hoursCompleted;
  final int totalHours;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.studentId,
    required this.name,
    required this.sectionId,
    required this.gender,
    this.company,
    required this.hoursCompleted,
    required this.totalHours,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentId: json['student_id'],
      name: json['name'],
      sectionId: json['section_id'],
      gender: json['gender'],
      company: json['company'],
      hoursCompleted: json['hours_completed'] ?? 0,
      totalHours: json['total_hours'] ?? 400,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  double get progressPercentage {
    return (hoursCompleted / totalHours) * 100;
  }
}