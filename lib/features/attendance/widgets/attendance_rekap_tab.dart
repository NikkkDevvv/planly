import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';

class AttendanceRekapTab extends StatelessWidget {
  final List<CourseModel> courses;
  final List<dynamic> records;

  const AttendanceRekapTab({
    super.key,
    required this.courses,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Daftarkan mata kuliah Anda terlebih dahulu untuk memantau rekap persentase kehadiran kuliah.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLightSecondary),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        mainAxisExtent: 156,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final courseRecords = records.where((r) => r['course_id'] == course.id).toList();
        final attendedCount = courseRecords.where((r) => r['status'] == 'Hadir').length;

        const targetSessions = 14;
        final double attendanceRate = (attendedCount / targetSessions) * 100;
        final bool isWarning = attendanceRate < 75;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isWarning ? const Color(0xFFFFF5F5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWarning ? Colors.red.withValues(alpha: 0.2) : AppColors.outlineLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${course.course_code} • ${course.credits} SKS',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLightSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Hadir: $attendedCount dari $targetSessions Sesi',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (isWarning)
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Kehadiran di bawah 75%! Terancam tidak dapat UAS.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Radial Progress Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      backgroundColor: Colors.transparent,
                      color: AppColors.outlineLight.withValues(alpha: 0.5),
                      strokeWidth: 7,
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: attendanceRate / 100.0,
                      backgroundColor: Colors.transparent,
                      color: isWarning ? AppColors.error : AppColors.primary,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${attendanceRate.round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isWarning ? AppColors.error : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
