import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../courses/bloc/courses_state.dart';
import '../../home/bloc/attendance_bloc.dart';
import '../../navigation/screens/main_layout.dart';
import '../../../data/models/course_model.dart';
import '../../schedules/bloc/schedules_bloc.dart';
import '../../schedules/bloc/schedules_event.dart';
import '../../schedules/bloc/schedules_state.dart';
import '../../../data/models/schedule_model.dart';
import '../widgets/attendance_mandiri_tab.dart';
import '../widgets/attendance_rekap_tab.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
    context.read<CoursesBloc>().add(FetchCourses());
    context.read<SchedulesBloc>().add(FetchSchedules());
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
                    'Verifikasi Foto Presensi',
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
                    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      AttendanceMandiriTab(
                        courses: courses,
                        reschedules: reschedules,
                        records: records,
                        onRefresh: _refreshData,
                        onShowPhotoPreview: _showPhotoPreview,
                        onShowDeleteConfirmation: _showDeleteConfirmation,
                        onLaunchMaps: _launchMaps,
                      ),
                      AttendanceRekapTab(
                        courses: courses,
                        records: records,
                      ),
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
}
