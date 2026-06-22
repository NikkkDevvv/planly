class ScheduleModel {
  final int? id;
  final int courseId;
  final String originalDate;
  final bool isCanceled;
  final String? newDate;
  final String? newStartTime;
  final String? newEndTime;
  final String? note;

  ScheduleModel({
    this.id,
    required this.courseId,
    required this.originalDate,
    required this.isCanceled,
    this.newDate,
    this.newStartTime,
    this.newEndTime,
    this.note,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      courseId: json['course_id'] is int ? json['course_id'] : int.parse(json['course_id'].toString()),
      originalDate: json['original_date'] ?? '',
      isCanceled: json['is_canceled'] is bool 
          ? json['is_canceled'] 
          : (json['is_canceled'] == 1 || json['is_canceled'] == 'true' || json['is_canceled'] == '1'),
      newDate: json['new_date'],
      newStartTime: json['new_start_time'],
      newEndTime: json['new_end_time'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'course_id': courseId,
      'original_date': originalDate,
      'is_canceled': isCanceled,
      'new_date': newDate,
      'new_start_time': newStartTime,
      'new_end_time': newEndTime,
      'note': note,
    };
  }
}
