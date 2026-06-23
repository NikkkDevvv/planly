import 'package:intl/intl.dart';
import '../../data/models/course_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/effective_course_model.dart';

class ScheduleHelper {
  static List<EffectiveCourse> getEffectiveCourses({
    required DateTime date,
    required List<CourseModel> courses,
    required List<ScheduleModel> reschedules,
  }) {
    final List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final selectedDayName = weekdays[date.weekday - 1].toLowerCase();
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(date);

    // Get regular courses for this day of week
    final regularCourses = courses
        .where((course) => course.day_of_week.toLowerCase() == selectedDayName)
        .toList();

    List<EffectiveCourse> effectiveCourses = [];

    for (final course in regularCourses) {
      // Check if there's a reschedule for this course on this date
      final reschedule = reschedules
          .where(
            (r) => r.courseId == course.id && r.originalDate == selectedDateStr,
          )
          .toList();

      if (reschedule.isNotEmpty) {
        final r = reschedule.first;
        if (r.isCanceled) {
          // Course is canceled on this date
          effectiveCourses.add(
            EffectiveCourse(
              course: course,
              isCanceled: true,
              isRescheduled: false,
              rescheduleNote: r.note,
              originalDate: r.originalDate,
            ),
          );
        } else {
          // Course is rescheduled away from this date
          if (r.newDate != selectedDateStr) {
            effectiveCourses.add(
              EffectiveCourse(
                course: course,
                isCanceled: false,
                isRescheduled: true,
                rescheduleNote: r.note,
                newDate: r.newDate,
                newStartTime: r.newStartTime,
                newEndTime: r.newEndTime,
                originalDate: r.originalDate,
              ),
            );
          }
        }
      } else {
        // No reschedule — regular class
        effectiveCourses.add(
          EffectiveCourse(
            course: course,
            isCanceled: false,
            isRescheduled: false,
          ),
        );
      }
    }

    // Check if any class is rescheduled TO this date
    final rescheduledToThisDate = reschedules
        .where((r) => !r.isCanceled && r.newDate == selectedDateStr)
        .toList();

    for (final r in rescheduledToThisDate) {
      final courseList = courses.where((c) => c.id == r.courseId).toList();
      if (courseList.isNotEmpty) {
        // Avoid duplicate if original day == new day
        final alreadyExists = effectiveCourses.any(
          (ec) => ec.course.id == courseList.first.id && ec.isRescheduled,
        );
        if (!alreadyExists) {
          effectiveCourses.add(
            EffectiveCourse(
              course: courseList.first,
              isCanceled: false,
              isRescheduled: false,
              isReplacementClass: true,
              overrideStartTime: r.newStartTime,
              overrideEndTime: r.newEndTime,
              rescheduleNote: r.note,
              originalDate: r.originalDate,
            ),
          );
        }
      }
    }

    // Sort by start time
    effectiveCourses.sort((a, b) {
      final aTime = a.overrideStartTime ?? a.course.start_time;
      final bTime = b.overrideStartTime ?? b.course.start_time;
      final aParts = aTime.split(':');
      final bParts = bTime.split(':');
      final aM = int.parse(aParts[0]) * 60 + int.parse(aParts[1]);
      final bM = int.parse(bParts[0]) * 60 + int.parse(bParts[1]);
      return aM.compareTo(bM);
    });

    return effectiveCourses;
  }
}
