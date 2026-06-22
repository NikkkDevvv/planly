import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../courses/bloc/courses_state.dart';
import '../../home/bloc/attendance_bloc.dart';
import '../../home/screens/attendance_checkin_screen.dart';
import '../../navigation/screens/main_layout.dart';
import '../../../data/models/course_model.dart';
import '../../schedules/bloc/schedules_bloc.dart';
import '../../schedules/bloc/schedules_event.dart';
import '../../schedules/bloc/schedules_state.dart';
import '../../../data/models/schedule_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 2, vsync: this);
    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
    context.read<CoursesBloc>().add(FetchCourses());
    context.read<SchedulesBloc>().add(FetchSchedules());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTodayName() {
    return _weekdays[DateTime.now().weekday - 1].toLowerCase();
  }

  String _formatIndonesianDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

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

  void _showPhotoPreview(String base64Image) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verifikasi Foto Wajah Absensi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLightPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: base64Image.startsWith('data:image')
                      ? Image.memory(
                          base64Decode(base64Image.split(',')[1]),
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int recordId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Presensi'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus riwayat presensi masuk ini? Penghapusan ini memungkinkan Anda melakukan absen ulang untuk kelas terkait.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<AttendanceBloc>().add(DeleteAttendanceRecord(recordId));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka link Google Maps')),
      );
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
            onPressed: () => context.findAncestorStateOfType<MainLayoutState>()?.openDrawer(),
          ),
        ),
        title: const Text(
          'Absensi Kuliah',
          style: TextStyle(
            color: AppColors.textLightPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLightSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.camera_alt_outlined, size: 20),
              text: 'Absen Mandiri',
            ),
            Tab(
              icon: Icon(Icons.pie_chart_outline, size: 20),
              text: 'Rekap Kehadiran',
            ),
          ],
        ),
      ),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, coursesState) {
          return BlocBuilder<SchedulesBloc, SchedulesState>(
            builder: (context, schedulesState) {
              return BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, attendanceState) {
                  if (coursesState is CoursesLoading ||
                      schedulesState is SchedulesLoading ||
                      attendanceState is AttendanceLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  List<CourseModel> courses = [];
                  if (coursesState is CoursesLoaded) {
                    courses = coursesState.courses;
                  }

                  List<ScheduleModel> reschedules = [];
                  if (schedulesState is SchedulesLoaded) {
                    reschedules = schedulesState.reschedules;
                  }

                  List<dynamic> records = [];
                  if (attendanceState is AttendanceHistoryLoaded) {
                    records = attendanceState.records;
                  } else if (attendanceState is AttendanceSuccess) {
                    // If success, refresh history
                    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAbsenMandiriTab(courses, reschedules, records),
                      _buildRekapKehadiranTab(courses, records),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAbsenMandiriTab(List<CourseModel> courses, List<ScheduleModel> reschedules, List<dynamic> records) {
    final effectiveCourses = _getEffectiveCourses(courses, reschedules);

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
        context.read<AttendanceBloc>().add(FetchAttendanceHistory());
        context.read<CoursesBloc>().add(FetchCourses());
        context.read<SchedulesBloc>().add(FetchSchedules());
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
                          ? Colors.orange.withOpacity(0.3)
                          : const Color(0xFF10B981).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
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
                              ? Colors.orange.withOpacity(0.1)
                              : const Color(0xFF10B981).withOpacity(0.1),
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
                            color: const Color(0xFF10B981).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sudah Presensi',
                                      style: TextStyle(
                                        color: const Color(0xFF10B981),
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
                                context.read<AttendanceBloc>().add(FetchAttendanceHistory());
                              }
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            label: const Text(
                              'Mulai Presensi Wajah',
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
                        color: AppColors.outlineLight.withOpacity(0.3),
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
                      'Tidak ada jadwal kuliah aktif yang sedang berlangsung saat ini. Fitur presensi wajah hanya dapat diakses saat jam perkuliahan berjalan.',
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
                    Icon(Icons.history_toggle_off, size: 48, color: AppColors.secondary.withOpacity(0.5)),
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
                          color: Colors.black.withOpacity(0.01),
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
                              _showPhotoPreview(record['image_base64']);
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
                                    color: Colors.black.withOpacity(0.3),
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
                                  onTap: () => _launchMaps(lat, lng),
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
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Hadir',
                                style: TextStyle(
                                  color: const Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                if (record['id'] != null) {
                                  _showDeleteConfirmation(record['id']);
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

  Widget _buildRekapKehadiranTab(List<CourseModel> courses, List<dynamic> records) {
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
              color: isWarning ? Colors.red.withOpacity(0.2) : AppColors.outlineLight,
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
                            color: const Color(0xFF10B981),
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
              // Radial Progress Ring (using Stack & CircularProgressIndicator)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      backgroundColor: Colors.transparent,
                      color: AppColors.outlineLight.withOpacity(0.5),
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

  List<_EffectiveCourse> _getEffectiveCourses(List<CourseModel> courses, List<ScheduleModel> reschedules) {
    final selectedDayName = _getTodayName();
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Get regular courses for this day of week
    final regularCourses = courses.where((course) =>
        course.day_of_week.toLowerCase() == selectedDayName).toList();

    // Build the effective daily course list considering reschedules
    List<_EffectiveCourse> effectiveCourses = [];

    for (final course in regularCourses) {
      // Check if there's a reschedule for this course on this date
      final reschedule = reschedules.where((r) =>
          r.courseId == course.id && r.originalDate == selectedDateStr).toList();

      if (reschedule.isNotEmpty) {
        final r = reschedule.first;
        if (r.isCanceled) {
          // Course is canceled on this date — show as canceled
          effectiveCourses.add(_EffectiveCourse(
            course: course,
            isCanceled: true,
            isRescheduled: false,
            rescheduleNote: r.note,
            originalDate: r.originalDate,
          ));
        } else {
          // Course is rescheduled away from this date — show as rescheduled away
          effectiveCourses.add(_EffectiveCourse(
            course: course,
            isCanceled: false,
            isRescheduled: true,
            rescheduleNote: r.note,
            newDate: r.newDate,
            newStartTime: r.newStartTime,
            newEndTime: r.newEndTime,
            originalDate: r.originalDate,
          ));
        }
      } else {
        // No reschedule — regular class
        effectiveCourses.add(_EffectiveCourse(
          course: course,
          isCanceled: false,
          isRescheduled: false,
        ));
      }
    }

    // Also check if any class is rescheduled TO this date
    final rescheduledToThisDate = reschedules.where((r) =>
        !r.isCanceled && r.newDate == selectedDateStr).toList();

    for (final r in rescheduledToThisDate) {
      final course = courses.where((c) => c.id == r.courseId).toList();
      if (course.isNotEmpty) {
        // Check if this course is not already in the list (avoid duplicate if original day == new day)
        final alreadyExists = effectiveCourses.any((ec) =>
            ec.course.id == course.first.id && ec.isRescheduled);
        if (!alreadyExists) {
          effectiveCourses.add(_EffectiveCourse(
            course: course.first,
            isCanceled: false,
            isRescheduled: false,
            isReplacementClass: true,
            overrideStartTime: r.newStartTime,
            overrideEndTime: r.newEndTime,
            rescheduleNote: r.note,
            originalDate: r.originalDate,
          ));
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

    return effectiveCourses;
  }
}

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
