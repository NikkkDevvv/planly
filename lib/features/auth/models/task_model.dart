class TaskModel {
  final int id;
  final int user_id;
  final int? course_id;
  final String title;
  final String? description;
  final String deadline_date;
  final String deadline_time;
  final String status;
  final bool is_priority;

  TaskModel({
    required this.id,
    required this.user_id,
    this.course_id,
    required this.title,
    this.description,
    required this.deadline_date,
    required this.deadline_time,
    required this.status,
    required this.is_priority,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      user_id: json['user_id'],
      course_id: json['course_id'],
      title: json['title'],
      description: json['description'],
      deadline_date: json['deadline_date'],
      deadline_time: json['deadline_time'],
      status: json['status'],
      is_priority: json['is_priority'] == 1 || json['is_priority'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'course_id': course_id,
      'title': title,
      'description': description,
      'deadline_date': deadline_date,
      'deadline_time': deadline_time,
      'status': status,
      'is_priority': is_priority,
    };
  }

  TaskModel copyWith({
    int? id,
    int? user_id,
    int? course_id,
    String? title,
    String? description,
    String? deadline_date,
    String? deadline_time,
    String? status,
    bool? is_priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      course_id: course_id ?? this.course_id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline_date: deadline_date ?? this.deadline_date,
      deadline_time: deadline_time ?? this.deadline_time,
      status: status ?? this.status,
      is_priority: is_priority ?? this.is_priority,
    );
  }
}