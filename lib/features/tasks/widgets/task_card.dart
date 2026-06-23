import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/course_model.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../screens/task_detail_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final List<CourseModel> courses;

  const TaskCard({
    super.key,
    required this.task,
    required this.courses,
  });

  String _getCourseName(List<CourseModel> courses, int? id) {
    if (id == null) return 'Umum / Personal';
    final course = courses.firstWhere(
      (c) => c.id == id,
      orElse: () => CourseModel(
        id: 0,
        user_id: 0,
        course_code: '',
        name: 'Tidak Diketahui',
        credits: 0,
        lecturer: '',
        room: '',
        day_of_week: '',
        start_time: '',
        end_time: '',
        color_hex: '#64748B',
      ),
    );
    return course.name;
  }

  String _formatDeadline(String dateStr, String timeStr) {
    try {
      DateTime dt = DateTime.parse("$dateStr $timeStr");
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime targetDate = DateTime(dt.year, dt.month, dt.day);

      String timePart = DateFormat('HH:mm').format(dt);

      if (targetDate == today) return "Hari Ini, $timePart";
      if (targetDate == today.subtract(const Duration(days: 1))) return "Kemarin, $timePart";
      if (targetDate == today.add(const Duration(days: 1))) return "Besok, $timePart";

      return "${DateFormat('EEEE, d MMM', 'id_ID').format(dt)}, $timePart";
    } catch (e) {
      return "$dateStr, $timeStr";
    }
  }

  bool _checkOverdue(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      return dt.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOverdue = _checkOverdue(task.deadline_date) && !task.is_finished;
    Color timeColor = isOverdue ? AppColors.error : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: task.is_finished,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      if (val == true) {
                        context.read<TasksBloc>().add(FinishTask(task.id));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLightPrimary,
                                decoration: task.is_finished ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (isOverdue)
                            _buildBadge("Terlambat", AppColors.errorContainer, AppColors.error)
                          else if (task.priority == 'high' && !task.is_finished)
                            _buildBadge("Prioritas Tinggi", AppColors.primaryContainer, AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCourseName(courses, task.course_id),
                        style: const TextStyle(color: AppColors.secondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: timeColor),
                          const SizedBox(width: 6),
                          Text(
                            _formatDeadline(task.deadline_date, task.deadline_time),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: timeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
