class NoteModel {
  final int id;
  final int user_id;
  final int? course_id;
  final String? courseName;
  final String title;
  final String content;
  final List<dynamic>? attachments;

  NoteModel({
    required this.id,
    required this.user_id,
    this.course_id,
    this.courseName,
    required this.title,
    required this.content,
    this.attachments,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      course_id: json['course_id'] is String 
          ? int.tryParse(json['course_id']) 
          : json['course_id'],
      courseName: json['course_name'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      attachments: json['attachments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'course_id': course_id,
      'title': title,
      'content': content,
      'attachments': attachments ?? [],
    };
  }

  NoteModel copyWith({
    int? id,
    int? user_id,
    int? course_id,
    String? courseName,
    String? title,
    String? content,
    List<dynamic>? attachments,
  }) {
    return NoteModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      course_id: course_id ?? this.course_id,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
    );
  }
}
