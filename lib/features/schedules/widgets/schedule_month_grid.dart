import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';

class ScheduleMonthGrid extends StatelessWidget {
  final DateTime viewedMonth;
  final DateTime selectedDate;
  final List<CourseModel> courses;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  const ScheduleMonthGrid({
    super.key,
    required this.viewedMonth,
    required this.selectedDate,
    required this.courses,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  final List<String> _weekdaysFull = const [
    'minggu',
    'senin',
    'selasa',
    'rabu',
    'kamis',
    'jumat',
    'sabtu',
  ];

  List<DateTime> _getMonthGridDays(DateTime monthDate) {
    final year = monthDate.year;
    final month = monthDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final startDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    return List.generate(42, (index) => startDay.add(Duration(days: index)));
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridDays = _getMonthGridDays(viewedMonth);
    final today = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'id_ID').format(viewedMonth).toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLightPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      onMonthChanged(DateTime(
                        viewedMonth.year,
                        viewedMonth.month - 1,
                        1,
                      ));
                    },
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      onMonthChanged(DateTime(
                        viewedMonth.year,
                        viewedMonth.month + 1,
                        1,
                      ));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day names row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text(
                'Min',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Sen',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Sel',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Rab',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Kam',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Jum',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'Sab',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          // Grid view
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              mainAxisExtent: 48,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final gridDay = gridDays[index];
              final bool isCurrentMonth = gridDay.month == viewedMonth.month;
              final bool isSelected = gridDay.day == selectedDate.day &&
                  gridDay.month == selectedDate.month &&
                  gridDay.year == selectedDate.year;
              final bool isToday = gridDay.day == today.day &&
                  gridDay.month == today.month &&
                  gridDay.year == today.year;

              final dayName = _weekdaysFull[gridDay.weekday % 7];
              final dayCourses = courses
                  .where((c) => c.day_of_week.toLowerCase() == dayName)
                  .toList();

              return GestureDetector(
                onTap: () => onDateSelected(gridDay),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday
                            ? AppColors.primaryContainer.withValues(alpha: 0.4)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isToday
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.outlineLight.withValues(alpha: 0.3),
                          ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        gridDay.day.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isCurrentMonth
                                  ? (isToday
                                      ? AppColors.primary
                                      : AppColors.textLightPrimary)
                                  : AppColors.textLightSecondary.withValues(
                                      alpha: 0.4,
                                    )),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dayCourses.take(3).map((c) {
                          return Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : _parseColor(c.color_hex),
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
