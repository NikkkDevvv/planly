class NoteModel {
  final int id;
  final int user_id;
  final int? course_id;
  final String title;
  final String content;

  NoteModel({
    required this.id,
    required this.user_id,
    this.course_id,
    required this.title,
    required this.content,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      course_id: json['course_id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'course_id': course_id,
      'title': title,
      'content': content,
    };
  }
}
