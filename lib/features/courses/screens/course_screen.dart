import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// [TESTING DOC] Import halaman tujuan navigasi
import 'add_course_screen.dart';
import 'course_detail_screen.dart';

class CoursesScreens extends StatelessWidget {
  const CoursesScreens({super.key});

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
            // Summary Header
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

            // Courses List / Grid
            _buildCourseCard(
              context, // [TESTING DOC] Passing context untuk navigasi
              courseCode: 'TIF301',
              courseName: 'Machine Learning',
              sks: '3 SKS',
              lecturer: 'Bpk. Supriyanto',
              schedule: 'Mon, Wed 10:00 - 11:30',
              location: 'Lab Komputer 1',
              accentColor: AppColors.primaryContainer,
              textColor: AppColors.primary,
            ),
            const SizedBox(height: 16),

            _buildCourseCard(
              context,
              courseCode: 'TIF302',
              courseName: 'Mobile Programming',
              sks: '3 SKS',
              lecturer: 'Tim Dosen Pengampu',
              schedule: 'Tue, Thu 13:00 - 14:30',
              location: 'Lab Mac / Studio',
              accentColor: const Color(0xFF10B981), // Hijau cerah
              textColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),

            _buildCourseCard(
              context,
              courseCode: 'TIF303',
              courseName: 'Data Communication',
              sks: '2 SKS',
              lecturer: 'Ibu Dosen Jaringan',
              schedule: 'Fri 09:00 - 11:00',
              location: 'Ruang Teori 2',
              accentColor: const Color(0xFFF59E0B), // Kuning/Oranye hangat
              textColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 16),

            _buildCourseCard(
              context,
              courseCode: 'TIF304',
              courseName: 'Operating Systems',
              sks: '3 SKS',
              lecturer: 'Bpk. Dosen OS',
              schedule: 'Wed 14:00 - 17:00',
              location: 'Ruang Teori 4',
              accentColor: const Color(0xFFEC4899), // Pink cerah
              textColor: const Color(0xFFEC4899),
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            // [TESTING DOC] Navigasi ke halaman Tambah Course
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCourseScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // rounded-full
          ),
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  // Widget pembantu untuk merender kartu mata kuliah
  Widget _buildCourseCard(
    BuildContext context, {
    required String courseCode,
    required String courseName,
    required String sks,
    required String lecturer,
    required String schedule,
    required String location,
    required Color accentColor,
    required Color textColor,
  }) {
    // [TESTING DOC] Membungkus dengan InkWell untuk interaksi klik ke halaman Detail
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CourseDetailScreen()),
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

  // Widget pembantu untuk detail baris dengan ikon
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
