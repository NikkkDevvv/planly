import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';
import '../../auth/models/course_model.dart';
import '../services/course_service.dart';

class CoursesScreens extends StatefulWidget {
  const CoursesScreens({super.key});

  @override
  State<CoursesScreens> createState() => _CoursesScreensState();
}

class _CoursesScreensState extends State<CoursesScreens> {
  final CourseService _courseService = CourseService();
  late Future<List<CourseModel>> _futureCourses;

  @override
  void initState() {
    super.initState();
    _futureCourses = _courseService.get_courses(1);
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 24,
          bottom: 96,
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semester 6 - 2026',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '18 SKS Enrolled • 6 Courses',
              style: TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<CourseModel>>(
              future: _futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada mata kuliah'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final course = snapshot.data![index];
                    final courseColor = _parseColor(course.color_hex);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildCourseCard(
                        context,
                        course: course,
                        courseCode: course.course_code,
                        courseName: course.name,
                        sks: '${course.credits} SKS',
                        lecturer: course.lecturer,
                        schedule:
                            '${course.day_of_week} ${course.start_time} - ${course.end_time}',
                        location: course.room,
                        accentColor: courseColor,
                        textColor: courseColor,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCourseScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context, {
    required CourseModel course,
    required String courseCode,
    required String courseName,
    required String sks,
    required String lecturer,
    required String schedule,
    required String location,
    required Color accentColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accentColor, width: 4)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseCode,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            courseName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sks,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCourseDetailRow(Icons.person, lecturer),
                const SizedBox(height: 8),
                _buildCourseDetailRow(Icons.schedule, schedule),
                const SizedBox(height: 8),
                _buildCourseDetailRow(Icons.location_on, location),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.secondary),
          ),
        ),
      ],
    );
  }
}
