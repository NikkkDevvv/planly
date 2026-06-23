import 'package:flutter/material.dart';
import '../../../core/widgets/interactive_empty_state.dart';
import '../../../core/utils/schedule_helper.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';
import '../screens/schedule_form_screen.dart';
import 'schedule_card.dart';

class ScheduleDailyTimeline extends StatelessWidget {
  final List<CourseModel> courses;
  final List<ScheduleModel> reschedules;
  final DateTime selectedDate;

  const ScheduleDailyTimeline({
    super.key,
    required this.courses,
    required this.reschedules,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCourses = ScheduleHelper.getEffectiveCourses(
      date: selectedDate,
      courses: courses,
      reschedules: reschedules,
    );

    if (effectiveCourses.isEmpty) {
      return InteractiveEmptyState(
        icon: Icons.event_busy,
        message: 'Tidak ada kelas kuliah untuk hari ini',
        actionLabel: 'Tambah Jadwal Baru',
        actionIcon: Icons.add,
        onActionPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScheduleFormScreen()),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
      itemCount: effectiveCourses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ec = effectiveCourses[index];

        return ScheduleCard(
          course: ec.course,
          isCanceled: ec.isCanceled,
          isRescheduled: ec.isRescheduled,
          isReplacementClass: ec.isReplacementClass,
          selectedDate: selectedDate,
          overrideStartTime: ec.overrideStartTime,
          overrideEndTime: ec.overrideEndTime,
          originalDate: ec.originalDate,
        );
      },
    );
  }
}
