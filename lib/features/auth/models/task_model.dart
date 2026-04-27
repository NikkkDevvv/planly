class TaskModel {
  final int id;
  final int userId;
  final int? courseId;
  final String title;
  final String? description;
  final String deadlineDate;
  final String deadlineTime;
  final String status;
  final bool isPriority;

  TaskModel({
    required this.id,
    required this.userId,
    this.courseId,
    required this.title,
    this.description,
    required this.deadlineDate,
    required this.deadlineTime,
    required this.status,
    required this.isPriority,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      deadlineDate: json['deadline_date'],
      deadlineTime: json['deadline_time'],
      status: json['status'],
      isPriority: json['is_priority'] == 1 || json['is_priority'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'deadline_date': deadlineDate,
      'deadline_time': deadlineTime,
      'status': status,
      'is_priority': isPriority,
    };
  }
}