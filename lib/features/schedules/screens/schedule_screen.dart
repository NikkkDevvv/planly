import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/interactive_empty_state.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';
import '../bloc/schedules_bloc.dart';
import '../bloc/schedules_event.dart';
import '../bloc/schedules_state.dart';
import '../../home/bloc/attendance_bloc.dart';
import '../../navigation/screens/main_layout.dart';
import 'schedule_form_screen.dart';

class ScheduleScreens extends StatefulWidget {
  const ScheduleScreens({super.key});

  @override
  State<ScheduleScreens> createState() => _ScheduleScreensState();
}

class _ScheduleScreensState extends State<ScheduleScreens> {
  late List<DateTime> _weekDates;
  bool _isMonthView = false;
  DateTime _viewedMonth = DateTime.now();

  final List<String> _weekdaysFull = [
    'minggu',
    'senin',
    'selasa',
    'rabu',
    'kamis',
    'jumat',
    'sabtu',
  ];

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
    context.read<SchedulesBloc>().add(FetchSchedules());
    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
  }

  void _generateWeekDates() {
    // Generates 7 days starting from today
    _weekDates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEEE', 'en_US').format(date);
  }

  List<DateTime> _getMonthGridDays(DateTime monthDate) {
    final year = monthDate.year;
    final month = monthDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    // Find Sunday before or equal to first day of the month
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
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => context
                .findAncestorStateOfType<MainLayoutState>()
                ?.openDrawer(),
          ),
        ),
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            color: AppColors.textLightPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Weekly vs Monthly Toggle Button
          IconButton(
            onPressed: () {
              setState(() {
                _isMonthView = !_isMonthView;
              });
            },
            icon: Icon(
              _isMonthView
                  ? Icons.view_week_outlined
                  : Icons.calendar_view_month_outlined,
              color: AppColors.primary,
            ),
            tooltip: _isMonthView ? 'Tampilan Mingguan' : 'Tampilan Bulanan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<SchedulesBloc, SchedulesState>(
        builder: (context, state) {
          if (state is SchedulesInitial || state is SchedulesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is SchedulesError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          } else if (state is SchedulesLoaded) {
            final courses = state.courses;
            final reschedules = state.reschedules;
            final selectedDate = state.selectedDate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Row (attendance, total schedules, rescheduled, canceled)
                _buildStatsPanel(courses, reschedules),

                // Calendar View section
                if (_isMonthView)
                  _buildMonthViewGrid(courses, selectedDate)
                else
                  _buildWeekDateStrip(courses, selectedDate),

                const SizedBox(height: 16),

                // Selected date daily classes timeline list
                Expanded(
                  child: _buildDailyTimeline(
                    courses,
                    reschedules,
                    selectedDate,
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScheduleFormScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsPanel(
    List<CourseModel> courses,
    List<ScheduleModel> reschedules,
  ) {
    int totalSchedules = courses.length;
    int rescheduledCount = reschedules.where((r) => !r.isCanceled).length;
    int canceledCount = reschedules.where((r) => r.isCanceled).length;

    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        int attendedCount = 0;
        if (state is AttendanceHistoryLoaded) {
          attendedCount = state.records.length;
        }

        double avgAttendance = 0.0;
        if (totalSchedules > 0) {
          avgAttendance = (attendedCount / (totalSchedules * 14)) * 100;
          if (avgAttendance > 100.0) avgAttendance = 100.0;
        }

        return Container(
          height: 80,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildStatCard(
                'Total Jadwal',
                '$totalSchedules Kelas',
                AppColors.primaryContainer,
                AppColors.primary,
              ),
              _buildStatCard(
                'Dipindahkan',
                '$rescheduledCount Sesi',
                AppColors.warningContainer,
                AppColors.warning,
              ),
              _buildStatCard(
                'Dibatalkan',
                '$canceledCount Sesi',
                const Color(0xFFFFDADC),
                AppColors.error,
              ),
              _buildStatCard(
                'Rerata Kehadiran',
                '${avgAttendance.round()}%',
                const Color(0xFF10B981).withOpacity(0.1),
                const Color(0xFF10B981),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textLightSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDateStrip(List<CourseModel> courses, DateTime selectedDate) {
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
                onTap: () {
                  context.read<SchedulesBloc>().add(SelectDate(DateTime.now()));
                },
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
              children: _weekDates.map((date) {
                bool isActive =
                    date.day == selectedDate.day &&
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
                    onTap: () {
                      context.read<SchedulesBloc>().add(SelectDate(date));
                    },
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

  Widget _buildMonthViewGrid(List<CourseModel> courses, DateTime selectedDate) {
    final gridDays = _getMonthGridDays(_viewedMonth);
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
                DateFormat(
                  'MMMM yyyy',
                  'id_ID',
                ).format(_viewedMonth).toUpperCase(),
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
                      setState(() {
                        _viewedMonth = DateTime(
                          _viewedMonth.year,
                          _viewedMonth.month - 1,
                          1,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _viewedMonth = DateTime(
                          _viewedMonth.year,
                          _viewedMonth.month + 1,
                          1,
                        );
                      });
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
          // 6x7 Grid view of days
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
              final bool isCurrentMonth = gridDay.month == _viewedMonth.month;
              final bool isSelected =
                  gridDay.day == selectedDate.day &&
                  gridDay.month == selectedDate.month &&
                  gridDay.year == selectedDate.year;
              final bool isToday =
                  gridDay.day == today.day &&
                  gridDay.month == today.month &&
                  gridDay.year == today.year;

              // Find courses scheduled on this weekday
              final dayName = _weekdaysFull[gridDay.weekday % 7];
              final dayCourses = courses
                  .where((c) => c.day_of_week.toLowerCase() == dayName)
                  .toList();

              return GestureDetector(
                onTap: () {
                  context.read<SchedulesBloc>().add(SelectDate(gridDay));
                  setState(() {
                    _isMonthView = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday
                              ? AppColors.primaryContainer.withOpacity(0.4)
                              : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isToday
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.outlineLight.withOpacity(0.3),
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
                                    : AppColors.textLightSecondary.withOpacity(
                                        0.4,
                                      )),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Dots penanda
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

  Widget _buildDailyTimeline(
    List<CourseModel> courses,
    List<ScheduleModel> reschedules,
    DateTime selectedDate,
  ) {
    final selectedDayName = _getDayName(selectedDate).toLowerCase();
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Get regular courses for this day of week
    final regularCourses = courses
        .where((course) => course.day_of_week.toLowerCase() == selectedDayName)
        .toList();

    // Build the effective daily course list considering reschedules
    List<_EffectiveCourse> effectiveCourses = [];

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
          // Course is canceled on this date — show as canceled
          effectiveCourses.add(
            _EffectiveCourse(
              course: course,
              isCanceled: true,
              isRescheduled: false,
              rescheduleNote: r.note,
              originalDate: r.originalDate,
            ),
          );
        } else {
          // Course is rescheduled away from this date.
          // If it is rescheduled to the same day, hide the original schedule 
          // and let the 'rescheduled TO this date' block below show the new one.
          if (r.originalDate != r.newDate) {
            effectiveCourses.add(
              _EffectiveCourse(
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
          _EffectiveCourse(
            course: course,
            isCanceled: false,
            isRescheduled: false,
          ),
        );
      }
    }

    // Also check if any class is rescheduled TO this date
    final rescheduledToThisDate = reschedules
        .where((r) => !r.isCanceled && r.newDate == selectedDateStr)
        .toList();

    for (final r in rescheduledToThisDate) {
      final course = courses.where((c) => c.id == r.courseId).toList();
      if (course.isNotEmpty) {
        // Check if this course is not already in the list as a replacement (to avoid duplicates from multiple reschedules, though unlikely)
        final alreadyReplacement = effectiveCourses.any(
          (ec) => ec.course.id == course.first.id && ec.isReplacementClass,
        );
        if (!alreadyReplacement) {
          effectiveCourses.add(
            _EffectiveCourse(
              course: course.first,
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

        return _buildScheduleCard(
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

  Widget _buildScheduleCard({
    required CourseModel course,
    required bool isCanceled,
    required bool isRescheduled,
    required DateTime selectedDate,
    bool isReplacementClass = false,
    String? overrideStartTime,
    String? overrideEndTime,
    String? originalDate,
  }) {
    Color accentColor = _parseColor(course.color_hex);
    final displayStartTime = overrideStartTime ?? course.start_time;
    final displayEndTime = overrideEndTime ?? course.end_time;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$displayStartTime - $displayEndTime',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLightPrimary,
                    decoration: isCanceled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.lecturer,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.room,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textLightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isCanceled && !isRescheduled && !isReplacementClass)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleFormScreen(
                                presetCourse: course,
                                presetDate: selectedDate,
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              context.read<SchedulesBloc>().add(
                                FetchSchedules(),
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.edit_calendar_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Reschedule',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (originalDate != null)
                      GestureDetector(
                        onTap: () {
                          context.read<SchedulesBloc>().add(
                            RemoveReschedule(
                              courseId: course.id,
                              originalDate: originalDate,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.restore_rounded,
                                size: 12,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Batal Reschedule',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCanceled
                    ? AppColors.error
                    : (isRescheduled
                          ? AppColors.warning
                          : (isReplacementClass
                                ? const Color(0xFF10B981)
                                : accentColor)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Text(
                isCanceled
                    ? 'BATAL'
                    : (isRescheduled
                          ? 'DIPINDAHKAN'
                          : (isReplacementClass ? 'PENGGANTI' : 'REGULAR')),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to represent a course in the daily timeline with reschedule info
class _EffectiveCourse {
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

  _EffectiveCourse({
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
