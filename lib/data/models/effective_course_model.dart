import 'course_model.dart';

class EffectiveCourse {
  final CourseModel course;
  final bool isCanceled;
  final bool isRescheduled;
  final bool isReplacementClass;
  final String? rescheduleNote;
  final String? newDate;
  final String? newStartTime;
  final String? newEndTime;
  final String? overrideStartTime;
  final String? overrideEndTime;
  final String? originalDate;

  EffectiveCourse({
    required this.course,
    required this.isCanceled,
    required this.isRescheduled,
    this.isReplacementClass = false,
    this.rescheduleNote,
    this.newDate,
    this.newStartTime,
    this.newEndTime,
    this.overrideStartTime,
    this.overrideEndTime,
    this.originalDate,
  });
}
