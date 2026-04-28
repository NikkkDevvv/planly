import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../../courses/services/course_service.dart';
import 'package:intl/intl.dart';

class ScheduleScreens extends StatefulWidget {
  const ScheduleScreens({super.key});

  @override
  State<ScheduleScreens> createState() => _ScheduleScreensState();
}

class _ScheduleScreensState extends State<ScheduleScreens> {
  final CourseService _courseService = CourseService();
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateWeekDates();
  }

  void _generateWeekDates() {
    // Menghasilkan 7 hari dimulai dari hari ini
    _weekDates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEEE').format(date); // Mengambil nama hari (Monday, Tuesday, dst)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MMMM').format(_selectedDate), // Nama Bulan Otomatis
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = DateTime.now();
                        });
                      },
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _weekDates.map((date) {
                      bool isActive = date.day == _selectedDate.day &&
                          date.month == _selectedDate.month;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: _buildDateItem(
                            day: DateFormat('E').format(date),
                            date: date.day.toString(),
                            isActive: isActive,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: FutureBuilder<List<CourseModel>>(
              future: _courseService.get_courses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Filter jadwal berdasarkan hari yang dipilih
                final selectedDayName = _getDayName(_selectedDate).toLowerCase();
                final dailyCourses = snapshot.data?.where((course) => 
                  course.day_of_week.toLowerCase() == selectedDayName
                ).toList() ?? [];

                if (dailyCourses.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                  itemCount: dailyCourses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final course = dailyCourses[index];
                    return _buildScheduleCard(
                      tag: 'Course',
                      tagColor: AppColors.primaryContainer,
                      tagTextColor: AppColors.primary,
                      title: course.name,
                      lecturer: course.lecturer,
                      time: '${course.start_time} - ${course.end_time}',
                      location: course.room,
                      accentColor: Color(int.parse(course.color_hex.replaceAll('#', '0xFF'))),
                      isPast: false, 
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: AppColors.outline.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "No classes for this day",
            style: TextStyle(color: AppColors.secondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem({
    required String day,
    required String date,
    required bool isActive,
  }) {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? null
            : Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white70 : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String title,
    required String lecturer,
    required String time,
    required String location,
    required Color accentColor,
    required bool isPast,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagTextColor),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lecturer,
                      style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 12, color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}