import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/interactive_empty_state.dart';
import '../../../data/models/effective_course_model.dart';
import '../bloc/attendance_bloc.dart';
import '../screens/attendance_checkin_screen.dart';

class HomeTimeline extends StatelessWidget {
  final List<EffectiveCourse> effectiveCourses;
  final DateTime currentTime;
  final VoidCallback onRefresh;

  const HomeTimeline({
    super.key,
    required this.effectiveCourses,
    required this.currentTime,
    required this.onRefresh,
  });

  bool _isClassActive(String startTime, String endTime) {
    try {
      final now = TimeOfDay.fromDateTime(currentTime);
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

  bool _isClassPassed(String endTime) {
    try {
      final now = TimeOfDay.fromDateTime(currentTime);
      final currentMinutes = now.hour * 60 + now.minute;

      final endParts = endTime.split(':');
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return currentMinutes > endMinutes;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (effectiveCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: InteractiveEmptyState(
          icon: Icons.calendar_today_outlined,
          message: 'Tidak Ada Kelas Hari Ini\nSantai sejenak! Anda tidak memiliki jadwal perkuliahan hari ini.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: effectiveCourses.length,
      itemBuilder: (context, index) {
        final ec = effectiveCourses[index];
        final isFirst = index == 0;
        final isLast = index == effectiveCourses.length - 1;

        final displayStartTime = ec.overrideStartTime ?? ec.course.start_time;
        final displayEndTime = ec.overrideEndTime ?? ec.course.end_time;

        final active = _isClassActive(displayStartTime, displayEndTime);
        final passed = _isClassPassed(displayEndTime);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Line & Dot
              SizedBox(
                width: 32,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    if (!isFirst)
                      Positioned(
                        top: 0,
                        height: 31,
                        child: Container(
                          width: 2,
                          color: AppColors.outlineLight,
                        ),
                      ),
                    if (!isLast)
                      Positioned(
                        top: 31,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: AppColors.outlineLight,
                        ),
                      ),
                    Positioned(
                      top: 24,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : (passed ? AppColors.secondary : Colors.white),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : (passed
                                    ? AppColors.secondary
                                    : AppColors.outlineLight),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 20, top: 12),
                  child: Opacity(
                    opacity: (passed || ec.isCanceled || ec.isRescheduled) ? 0.6 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.outlineLight,
                        ),
                        boxShadow: [
                          if (active)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            )
                          else
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$displayStartTime - $displayEndTime',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.textLightSecondary,
                                ),
                              ),
                              Row(
                                children: [
                                  if (ec.isCanceled)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFDADC),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Batal',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    )
                                  else if (ec.isRescheduled)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warningContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Dipindahkan',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    )
                                  else if (ec.isReplacementClass)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Kelas Pengganti',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ),
                                  if (active &&
                                      !ec.isCanceled &&
                                      !ec.isRescheduled) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Aktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ec.course.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLightPrimary,
                              decoration: (passed || ec.isCanceled || ec.isRescheduled)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ec.course.lecturer,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ec.course.room,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),

                          // Check-in Button (if class is active and not canceled/rescheduled)
                          if (active && !ec.isCanceled && !ec.isRescheduled) ...[
                            const SizedBox(height: 16),
                            BlocBuilder<AttendanceBloc, AttendanceState>(
                              builder: (context, state) {
                                bool hasAttended = false;
                                if (state is AttendanceHistoryLoaded) {
                                  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                                  hasAttended = state.records.any((record) {
                                    return record['course_id'] == ec.course.id &&
                                        record['date'] == todayStr;
                                  });
                                }

                                if (hasAttended) {
                                  return ElevatedButton.icon(
                                    onPressed: null, // Disabled
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Sudah Presensi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      disabledBackgroundColor: Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }

                                return ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AttendanceCheckinScreen(
                                              courseId: ec.course.id,
                                              courseCode: ec.course.course_code,
                                              courseName: ec.course.name,
                                            ),
                                      ),
                                    ).then((_) => onRefresh()); // Refresh attendance on return
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Kirim Presensi Kehadiran',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
