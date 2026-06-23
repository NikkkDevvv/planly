import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';

class ScheduleWeekStrip extends StatelessWidget {
  final List<DateTime> weekDates;
  final List<CourseModel> courses;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onTodayPressed;

  const ScheduleWeekStrip({
    super.key,
    required this.weekDates,
    required this.courses,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onTodayPressed,
  });

  String _getDayName(DateTime date) {
    return DateFormat('EEEE', 'en_US').format(date);
  }

  Widget _buildDateItem({
    required String day,
    required String date,
    required bool isActive,
    required bool hasDot,
  }) {
    return Container(
      width: 52,
      height: 76,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? null : Border.all(color: AppColors.outlineLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white70 : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.textLightPrimary,
            ),
          ),
          if (hasDot) ...[
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'id_ID').format(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLightPrimary,
                ),
              ),
              GestureDetector(
                onTap: onTodayPressed,
                child: const Text(
                  'Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: weekDates.map((date) {
                bool isActive = date.day == selectedDate.day &&
                    date.month == selectedDate.month &&
                    date.year == selectedDate.year;

                // Check if classes exist on this weekday
                final dayName = _getDayName(date).toLowerCase();
                final hasCourses = courses.any(
                  (c) => c.day_of_week.toLowerCase() == dayName,
                );

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: _buildDateItem(
                      day: DateFormat('E', 'id_ID').format(date),
                      date: date.day.toString(),
                      isActive: isActive,
                      hasDot: hasCourses,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
