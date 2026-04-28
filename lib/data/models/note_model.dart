class NoteModel {
  final int id;
  final int userId;
  final int? courseId;
  final String title;
  final String content;

  NoteModel({
    required this.id,
    required this.userId,
    this.courseId,
    required this.title,
    required this.content,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'content': content,
    };
  }
}