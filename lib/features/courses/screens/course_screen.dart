import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';
import '../../../data/models/course_model.dart';
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
    // Memanggil API tanpa parameter karena user_id biasanya diambil dari Token di Backend
    _futureCourses = _courseService.get_courses();
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return AppColors.primary; // Warna fallback jika hex rusak
    }
  }

  // Fungsi untuk menghitung total SKS secara dinamis
  int _calculateTotalSKS(List<CourseModel> courses) {
    return courses.fold(0, (sum, item) => sum + item.credits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<List<CourseModel>>(
        future: _futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final courses = snapshot.data ?? [];
          final totalSKS = _calculateTotalSKS(courses);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureCourses = _courseService.get_courses();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  // Header sekarang dinamis berdasarkan data API
                  Text(
                    '$totalSKS SKS Enrolled • ${courses.length} Courses',
                    style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 24),
                  
                  if (courses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Column(
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: AppColors.outline.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text(
                              'No courses found.\nTap + to add your first course.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
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
                            schedule: '${course.day_of_week}, ${course.start_time} - ${course.end_time}',
                            location: course.room,
                            accentColor: courseColor,
                            textColor: courseColor,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );

          if (result == true) {
            setState(() {
              _futureCourses = _courseService.get_courses();
            });
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
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
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
        // Refresh jika ada perubahan (Edit/Delete) dari layar detail
        if (result == true) {
          setState(() {
            _futureCourses = _courseService.get_courses();
          });
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
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
                          Text(
                            courseCode,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: textColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sks,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        courseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCourseInfoRow(Icons.person_outline, lecturer),
                      const SizedBox(height: 4),
                      _buildCourseInfoRow(Icons.access_time, schedule),
                      const SizedBox(height: 4),
                      _buildCourseInfoRow(Icons.location_on_outlined, location),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.secondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13, 
              color: AppColors.secondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}