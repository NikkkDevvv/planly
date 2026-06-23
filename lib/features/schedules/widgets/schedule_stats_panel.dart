import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../home/bloc/attendance_bloc.dart';

class ScheduleStatsPanel extends StatelessWidget {
  final List<CourseModel> courses;
  final List<ScheduleModel> reschedules;

  const ScheduleStatsPanel({
    super.key,
    required this.courses,
    required this.reschedules,
  });

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

  @override
  Widget build(BuildContext context) {
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
                const Color(0xFF10B981).withValues(alpha: 0.1),
                const Color(0xFF10B981),
              ),
            ],
          ),
        );
      },
    );
  }
}
