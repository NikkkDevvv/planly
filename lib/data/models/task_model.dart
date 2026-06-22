class TaskModel {
  final int id;
  final int user_id;
  final int? course_id;
  final String? course_code;
  final String? course_name;
  final String title;
  final String? description;
  final String deadline_date;
  final String deadline_time;
  final bool is_finished;
  final String priority;
  final List<dynamic>? attachments;

  TaskModel({
    required this.id,
    required this.user_id,
    this.course_id,
    this.course_code,
    this.course_name,
    required this.title,
    this.description,
    required this.deadline_date,
    required this.deadline_time,
    required this.is_finished,
    required this.priority,
    this.attachments,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      course_id: json['course_id'] is String 
          ? int.tryParse(json['course_id']) 
          : json['course_id'],
      course_code: json['course_code'],
      course_name: json['course_name'],
      title: json['task_title'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      deadline_date: json['deadline_date'] ?? (json['deadline']?.toString().split(' ')[0] ?? ''),
      deadline_time: json['deadline_time'] ?? (json['deadline']?.toString().split(' ').length == 2 
          ? json['deadline'].toString().split(' ')[1] 
          : '23:59:00'),
      is_finished: json['is_finished'] == 1 || json['is_finished'] == true,
      priority: json['priority']?.toString() ?? 
          ((json['is_priority'] == 1 || json['is_priority'] == true) ? 'high' : 'medium'),
      attachments: json['attachments'],
    );
  }

  bool get is_priority => priority.toLowerCase() == 'high';

  Map<String, dynamic> toJson() {
    return {
      'course_id': course_id,
      'task_title': title,
      'description': description,
      'deadline': '$deadline_date $deadline_time',
      'is_priority': priority.toLowerCase() == 'high',
      'is_finished': is_finished,
      'attachments': attachments ?? [],
    };
  }

  TaskModel copyWith({
    int? id,
    int? user_id,
    int? course_id,
    String? course_code,
    String? course_name,
    String? title,
    String? description,
    String? deadline_date,
    String? deadline_time,
    bool? is_finished,
    String? priority,
    List<dynamic>? attachments,
  }) {
    return TaskModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      course_id: course_id ?? this.course_id,
      course_code: course_code ?? this.course_code,
      course_name: course_name ?? this.course_name,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline_date: deadline_date ?? this.deadline_date,
      deadline_time: deadline_time ?? this.deadline_time,
      is_finished: is_finished ?? this.is_finished,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
    );
  }
}