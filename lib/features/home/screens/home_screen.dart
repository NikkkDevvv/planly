import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/task_model.dart';
import '../../courses/services/course_service.dart';
import '../../tasks/services/task_service.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  final CourseService _courseService = CourseService();
  final TaskService _taskService = TaskService();

  late Future<List<CourseModel>> _futureCourses;
  late Future<List<TaskModel>> _futureTasks;

  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _futureCourses = _courseService.get_courses();
    _futureTasks = _taskService.get_all_tasks();
  }

  String _getTodayName() {
    return _weekdays[DateTime.now().weekday - 1];
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${_getTodayName()}, ${months[now.month]} ${now.day}';
  }

  bool _isClassActive(String startTime, String endTime) {
    try {
      final now = TimeOfDay.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final startParts = startTime.split(':');
      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

      final endParts = endTime.split(':');
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } catch (e) {
      return false;
    }
  }

  List<CourseModel> _sortCoursesByTime(List<CourseModel> courses) {
    courses.sort((a, b) {
      final aParts = a.start_time.split(':');
      final bParts = b.start_time.split(':');
      final aMinutes = int.parse(aParts[0]) * 60 + int.parse(aParts[1]);
      final bMinutes = int.parse(bParts[0]) * 60 + int.parse(bParts[1]);
      return aMinutes.compareTo(bMinutes);
    });
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getFormattedDate(),
            style: const TextStyle(fontSize: 16, color: AppColors.secondary),
          ),
          const SizedBox(height: 32),
          FutureBuilder<List<CourseModel>>(
            future: _futureCourses,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Connection Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }

              final todayName = _getTodayName().toLowerCase();
              final todayCourses =
                  snapshot.data
                      ?.where(
                        (course) =>
                            course.day_of_week.toLowerCase() == todayName,
                      )
                      .toList() ??
                  [];

              if (todayCourses.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "No classes for today.",
                    style: TextStyle(color: AppColors.secondary),
                  ),
                );
              }

              final sortedCourses = _sortCoursesByTime(todayCourses);

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedCourses.length,
                itemBuilder: (context, index) {
                  final course = sortedCourses[index];
                  final isActive = _isClassActive(
                    course.start_time,
                    course.end_time,
                  );

                  return _buildTimelineItem(
                    time: "${course.start_time} - ${course.end_time}",
                    title: course.name,
                    room: course.room,
                    lecturer: course.lecturer,
                    status: isActive ? "In Progress" : null,
                    isFirst: index == 0,
                    isLast: index == sortedCourses.length - 1,
                    isActive: isActive,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 48),
          const Text(
            "Quick Tasks",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<TaskModel>>(
            future: _futureTasks,
            builder: (context, snapshot) {
              int pendingCount = 0;
              String topTaskTitle = "Clean schedule";

              if (snapshot.hasData) {
                final pendingTasks = snapshot.data!
                    .where((t) => !t.is_finished)
                    .toList();
                pendingCount = pendingTasks.length;
                if (pendingCount > 0) {
                  topTaskTitle = pendingTasks.first.title;
                }
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildBentoCard(
                      color: const Color(0xFFE2DFFF),
                      icon: Icons.assignment_turned_in,
                      iconColor: AppColors.primary,
                      value: pendingCount.toString(),
                      label: "Pending",
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBentoCard(
                      color: AppColors.surfaceContainerHigh,
                      icon: Icons.menu_book,
                      iconColor: AppColors.secondary,
                      value: topTaskTitle,
                      label: "Current Focus",
                      isNumber: false,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String room,
    required String lecturer,
    String? status,
    bool isFirst = false,
    bool isLast = false,
    bool isActive = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isLast)
                  const VerticalDivider(
                    thickness: 1.5,
                    color: AppColors.outlineVariant,
                  ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary.withOpacity(0.5)
                            : AppColors.outlineVariant.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (status != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildIconText(Icons.location_on_outlined, room),
                        const SizedBox(height: 6),
                        _buildIconText(Icons.person_outline, lecturer),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isNumber,
  }) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isNumber ? 32 : 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
