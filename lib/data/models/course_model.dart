class CourseModel {
  final int id;
  final int user_id;
  final String course_code;
  final String name;
  final int credits;
  final String lecturer;
  final String room;
  final String day_of_week;
  final String start_time;
  final String end_time;
  final String color_hex;

  CourseModel({
    required this.id,
    required this.user_id,
    required this.course_code,
    required this.name,
    required this.credits,
    required this.lecturer,
    required this.room,
    required this.day_of_week,
    required this.start_time,
    required this.end_time,
    required this.color_hex,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      user_id: json['user_id'],
      course_code: json['course_code'],
      name: json['name'],
      credits: json['credits'],
      lecturer: json['lecturer'],
      room: json['room'],
      day_of_week: json['day_of_week'],
      start_time: json['start_time'],
      end_time: json['end_time'],
      color_hex: json['color_hex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'course_code': course_code,
      'name': name,
      'credits': credits,
      'lecturer': lecturer,
      'room': room,
      'day_of_week': day_of_week,
      'start_time': start_time,
      'end_time': end_time,
      'color_hex': color_hex,
    };
  }

  CourseModel copyWith({
    int? id,
    int? user_id,
    String? course_code,
    String? name,
    int? credits,
    String? lecturer,
    String? room,
    String? day_of_week,
    String? start_time,
    String? end_time,
    String? color_hex,
  }) {
    return CourseModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      course_code: course_code ?? this.course_code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      lecturer: lecturer ?? this.lecturer,
      room: room ?? this.room,
      day_of_week: day_of_week ?? this.day_of_week,
      start_time: start_time ?? this.start_time,
      end_time: end_time ?? this.end_time,
      color_hex: color_hex ?? this.color_hex,
    );
  }
}