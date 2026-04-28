class TaskModel {
  final int id;
  final int user_id;
  final int? course_id;
  final String title;
  final String? description;
  final String deadline_date;
  final String deadline_time;
  final bool is_finished;
  final bool is_priority;

  TaskModel({
    required this.id,
    required this.user_id,
    this.course_id,
    required this.title,
    this.description,
    required this.deadline_date,
    required this.deadline_time,
    required this.is_finished,
    required this.is_priority,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    String rawDeadline = json['deadline'] ?? '';
    List<String> splitDeadline = rawDeadline.contains(' ') 
        ? rawDeadline.split(' ') 
        : [rawDeadline, '00:00:00'];

    return TaskModel(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      course_id: json['course_id'] is String 
          ? int.tryParse(json['course_id']) 
          : json['course_id'],
      title: json['task_title'] ?? '',
      description: json['description'] ?? '',
      deadline_date: splitDeadline[0],
      deadline_time: splitDeadline[1],
      is_finished: json['is_finished'] == 1 || json['is_finished'] == true,
      is_priority: json['is_priority'] == 1 || json['is_priority'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'course_id': course_id,
      'task_title': title,
      'description': description,
      'deadline': '$deadline_date $deadline_time',
      'is_finished': is_finished ? 1 : 0,
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
    bool? is_finished,
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
      is_finished: is_finished ?? this.is_finished,
      is_priority: is_priority ?? this.is_priority,
    );
  }
}