import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/schedule_helper.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../home/bloc/attendance_bloc.dart';
import '../../home/screens/attendance_checkin_screen.dart';

class AttendanceMandiriTab extends StatelessWidget {
  final List<CourseModel> courses;
  final List<ScheduleModel> reschedules;
  final List<dynamic> records;
  final VoidCallback onRefresh;
  final ValueChanged<String> onShowPhotoPreview;
  final ValueChanged<int> onShowDeleteConfirmation;
  final Function(double, double) onLaunchMaps;

  const AttendanceMandiriTab({
    super.key,
    required this.courses,
    required this.reschedules,
    required this.records,
    required this.onRefresh,
    required this.onShowPhotoPreview,
    required this.onShowDeleteConfirmation,
    required this.onLaunchMaps,
  });

  bool _isClassActive(String startTime, String endTime) {
    try {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final startParts = startTime.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

      final endParts = endTime.split(':');
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } catch (e) {
      return false;
    }
  }

  bool _checkIfCheckedIn(List<dynamic> records, int courseId) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return records.any((r) =>
        r['course_id'] == courseId &&
        r['date'] == todayStr &&
        r['status'] == 'Hadir');
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: AppColors.textLightSecondary, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textLightPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCourses = ScheduleHelper.getEffectiveCourses(
      date: DateTime.now(),
      courses: courses,
      reschedules: reschedules,
    );

    // Filter to active courses (where class is active and not canceled/rescheduled away)
    final activeCourses = effectiveCourses.where((ec) {
      if (ec.isCanceled || ec.isRescheduled) return false;
      final startTime = ec.overrideStartTime ?? ec.course.start_time;
      final endTime = ec.overrideEndTime ?? ec.course.end_time;
      return _isClassActive(startTime, endTime);
    }).toList();

    final todayVisibleCourses = effectiveCourses.where((ec) => !ec.isCanceled && !ec.isRescheduled).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        onRefresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active class card or Lock state
            if (activeCourses.isNotEmpty)
              ...activeCourses.map((ec) {
                final course = ec.course;
                final displayStartTime = ec.overrideStartTime ?? course.start_time;
                final displayEndTime = ec.overrideEndTime ?? course.end_time;
                final isAlreadyCheckedIn = _checkIfCheckedIn(records, course.id);
                final checkInRecord = records.firstWhere(
                  (r) => r['course_id'] == course.id && r['date'] == DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  orElse: () => null,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ec.isReplacementClass
                          ? Colors.orange.withValues(alpha: 0.3)
                          : const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ec.isReplacementClass
                              ? Colors.orange.withValues(alpha: 0.1)
                              : const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ec.isReplacementClass
                              ? '🔴 KELAS PENGGANTI AKTIF HARI INI'
                              : '🔴 KELAS KULIAH AKTIF HARI INI',
                          style: TextStyle(
                            color: ec.isReplacementClass ? Colors.orange : const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLightPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course.course_code} • ${course.credits} SKS',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLightSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.access_time_outlined, 'Jam Kuliah', '$displayStartTime - $displayEndTime'),
                      _buildDetailRow(Icons.location_on_outlined, 'Ruangan', course.room),
                      _buildDetailRow(Icons.person_outline, 'Dosen', course.lecturer),
                      const SizedBox(height: 20),
                      if (isAlreadyCheckedIn)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sudah Presensi',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Hadir pukul ${checkInRecord?['time'] ?? ''}',
                                      style: const TextStyle(
                                        color: AppColors.textLightSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceCheckinScreen(
                                    courseId: course.id,
                                    courseCode: course.course_code,
                                    courseName: course.name,
                                  ),
                                ),
                              );
                              if (result == true) {
                                onRefresh();
                              }
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            label: const Text(
                              'Mulai Presensi Foto',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              })
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.outlineLight.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline, size: 36, color: AppColors.secondary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Absensi Belum Dibuka',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tidak ada jadwal kuliah aktif yang sedang berlangsung saat ini. Fitur presensi hanya dapat diakses saat jam perkuliahan berjalan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLightSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JADWAL HARI INI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (todayVisibleCourses.isEmpty)
                            const Text(
                              'Tidak ada jadwal kuliah hari ini.',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textLightSecondary,
                              ),
                            )
                          else
                            ...todayVisibleCourses.map((ec) {
                              final c = ec.course;
                              final startTime = ec.overrideStartTime ?? c.start_time;
                              final endTime = ec.overrideEndTime ?? c.end_time;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textLightPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Ruang: ${c.room}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textLightSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$startTime - $endTime',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),
            // History logs list
            const Text(
              'Riwayat Presensi Masuk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history_toggle_off, size: 48, color: AppColors.secondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada riwayat presensi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final bool hasGPS = record['latitude'] != null && record['longitude'] != null;
                  final double? lat = record['latitude'] != null ? double.tryParse(record['latitude'].toString()) : null;
                  final double? lng = record['longitude'] != null ? double.tryParse(record['longitude'].toString()) : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.01),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left photo thumbnail
                        GestureDetector(
                          onTap: () {
                            if (record['image_base64'] != null) {
                              onShowPhotoPreview(record['image_base64']);
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.bgLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.outlineLight),
                                  image: record['image_base64'] != null && record['image_base64'].startsWith('data:image')
                                      ? DecorationImage(
                                          image: MemoryImage(base64Decode(record['image_base64'].split(',')[1])),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: record['image_base64'] == null
                                    ? const Icon(Icons.person, color: AppColors.secondary, size: 20)
                                    : null,
                              ),
                              if (record['image_base64'] != null)
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 16),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Middle Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record['course_name'] ?? 'Mata Kuliah',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLightPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${record['date']} • ${record['time']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLightSecondary,
                                ),
                              ),
                              if (hasGPS && lat != null && lng != null) ...[
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => onLaunchMaps(lat, lng),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.language_outlined, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ],
                          ),
                        ),
                        // Right status & delete
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Hadir',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                if (record['id'] != null) {
                                  onShowDeleteConfirmation(record['id']);
                                }
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
