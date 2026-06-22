import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/interactive_empty_state.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../tasks/bloc/tasks_state.dart';
import '../../schedules/bloc/schedules_bloc.dart';
import '../../schedules/bloc/schedules_event.dart';
import '../../schedules/bloc/schedules_state.dart';
import '../bloc/pomodoro_bloc.dart';
import '../../navigation/screens/main_layout.dart';
import 'attendance_checkin_screen.dart';
import '../bloc/attendance_bloc.dart';
import '../../events/bloc/campus_events_bloc.dart';
import '../../events/bloc/campus_events_event.dart';
import '../../events/bloc/campus_events_state.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

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
    // Dynamic clock ticking every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    // Refresh Blocs
    context.read<CoursesBloc>().add(FetchCourses());
    context.read<TasksBloc>().add(FetchTasks());
    context.read<SchedulesBloc>().add(FetchSchedules());
    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
    context.read<CampusEventsBloc>().add(FetchCampusEvents());
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    context.read<CoursesBloc>().add(FetchCourses());
    context.read<TasksBloc>().add(FetchTasks());
    context.read<SchedulesBloc>().add(FetchSchedules());
    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
    context.read<CampusEventsBloc>().add(FetchCampusEvents());
  }

  String _getTodayName() {
    return _weekdays[_currentTime.weekday - 1];
  }

  String _getFormattedDate() {
    const daysIndo = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    const monthsIndo = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${daysIndo[_currentTime.weekday % 7]}, ${_currentTime.day} ${monthsIndo[_currentTime.month]}';
  }

  String _getFormattedClock() {
    return DateFormat('HH:mm:ss').format(_currentTime);
  }

  bool _isClassActive(String startTime, String endTime) {
    try {
      final now = TimeOfDay.fromDateTime(_currentTime);
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
      final now = TimeOfDay.fromDateTime(_currentTime);
      final currentMinutes = now.hour * 60 + now.minute;

      final endParts = endTime.split(':');
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return currentMinutes > endMinutes;
    } catch (e) {
      return false;
    }
  }

  List<CourseModel> _sortCoursesByTime(List<CourseModel> courses) {
    courses.sort((a, b) {
      final aParts = a.start_time.split(':');
      final bParts = b.start_time.split(':');
      final aMinutes = int.parse(aParts[0]) * 60 + int.parse(aParts[1]);
      final bMinutes = int.parse(bParts[0]) * 60 + int.parse(bParts[1]);
      return aMinutes.compareTo(bMinutes);
    });
    return courses;
  }

  List<_EffectiveCourse> _getEffectiveCourses(
    List<CourseModel> courses,
    List<ScheduleModel> reschedules,
  ) {
    final selectedDayName = _getTodayName().toLowerCase();
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_currentTime);

    // Get regular courses for this day of week
    final regularCourses = courses
        .where((course) => course.day_of_week.toLowerCase() == selectedDayName)
        .toList();

    // Build the effective daily course list considering reschedules
    List<_EffectiveCourse> effectiveCourses = [];

    for (final course in regularCourses) {
      // Check if there's a reschedule for this course on this date
      final reschedule = reschedules
          .where(
            (r) => r.courseId == course.id && r.originalDate == selectedDateStr,
          )
          .toList();

      if (reschedule.isNotEmpty) {
        final r = reschedule.first;
        if (r.isCanceled) {
          // Course is canceled on this date — show as canceled
          effectiveCourses.add(
            _EffectiveCourse(
              course: course,
              isCanceled: true,
              isRescheduled: false,
              rescheduleNote: r.note,
              originalDate: r.originalDate,
            ),
          );
        } else {
          // Course is rescheduled away from this date
          // If it is rescheduled to the SAME day, do not add this "original/rescheduled away" instance.
          // The "rescheduled TO this date" loop below will add the new version.
          if (r.newDate != selectedDateStr) {
            effectiveCourses.add(
              _EffectiveCourse(
                course: course,
                isCanceled: false,
                isRescheduled: true,
                rescheduleNote: r.note,
                newDate: r.newDate,
                newStartTime: r.newStartTime,
                newEndTime: r.newEndTime,
                originalDate: r.originalDate,
              ),
            );
          }
        }
      } else {
        // No reschedule — regular class
        effectiveCourses.add(
          _EffectiveCourse(
            course: course,
            isCanceled: false,
            isRescheduled: false,
          ),
        );
      }
    }

    // Also check if any class is rescheduled TO this date
    final rescheduledToThisDate = reschedules
        .where((r) => !r.isCanceled && r.newDate == selectedDateStr)
        .toList();

    for (final r in rescheduledToThisDate) {
      final course = courses.where((c) => c.id == r.courseId).toList();
      if (course.isNotEmpty) {
        // Check if this course is not already in the list (avoid duplicate if original day == new day)
        final alreadyExists = effectiveCourses.any(
          (ec) => ec.course.id == course.first.id && ec.isRescheduled,
        );
        if (!alreadyExists) {
          effectiveCourses.add(
            _EffectiveCourse(
              course: course.first,
              isCanceled: false,
              isRescheduled: false,
              isReplacementClass: true,
              overrideStartTime: r.newStartTime,
              overrideEndTime: r.newEndTime,
              rescheduleNote: r.note,
              originalDate: r.originalDate,
            ),
          );
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

  ImageProvider? _getProfileImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64String = url.split('base64,').last;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        return null;
      }
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    try {
      return MemoryImage(base64Decode(url));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => context
                .findAncestorStateOfType<MainLayoutState>()
                ?.openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String userName = 'Mahasiswa';
            ImageProvider? avatarProvider;
            if (state is Authenticated) {
              userName = state.user.name.split(' ')[0];
              avatarProvider = _getProfileImageProvider(
                state.user.profile_photo_url,
              );
            }
            return Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  'Halo, $userName!',
                  style: const TextStyle(
                    color: AppColors.textLightPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              _getFormattedClock(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bento Stats Grid (Redesigned to a premium 3-card layout)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Stacked Cards (Tugas Aktif & Kelas Hari Ini)
                  Expanded(
                    child: Column(
                      children: [
                        // Card A: Tugas Aktif
                        BlocBuilder<TasksBloc, TasksState>(
                          builder: (context, state) {
                            int pendingCount = 0;
                            if (state is TasksLoaded) {
                              pendingCount = state.tasks
                                  .where((t) => !t.is_finished)
                                  .length;
                            }
                            return _buildSmallBentoCard(
                              color: const Color(0xFFFFEAEA), // Soft red
                              icon: Icons.checklist_rounded,
                              iconColor: const Color(0xFFEF4444),
                              value: '$pendingCount',
                              label: 'Tugas Aktif',
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Card B: Kelas Hari Ini
                        BlocBuilder<SchedulesBloc, SchedulesState>(
                          builder: (context, state) {
                            int todayCoursesCount = 0;
                            if (state is SchedulesLoaded) {
                              final effective = _getEffectiveCourses(
                                state.courses,
                                state.reschedules,
                              );
                              todayCoursesCount = effective
                                  .where(
                                    (ec) => !ec.isCanceled && !ec.isRescheduled,
                                  )
                                  .length;
                            }
                            return _buildSmallBentoCard(
                              color: const Color(
                                0xFFE6FDF4,
                              ), // Soft emerald green
                              icon: Icons.menu_book_rounded,
                              iconColor: const Color(0xFF10B981),
                              value: '$todayCoursesCount',
                              label: 'Kelas Hari Ini',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right Column: Tall Pomodoro Card
                  Expanded(
                    child: BlocBuilder<PomodoroBloc, PomodoroState>(
                      builder: (context, state) {
                        return _buildTallPomodoroCard(
                          color: const Color(0xFFEEF2FF), // Soft indigo
                          icon: state.isBreak
                              ? Icons.coffee_rounded
                              : Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFF6366F1),
                          timerValue: state.formattedTime,
                          label: state.isBreak
                              ? 'Waktu Istirahat'
                              : 'Fokus Pomodoro',
                          isRunning: state.isRunning,
                          onPlayPause: () {
                            if (state.isRunning) {
                              context.read<PomodoroBloc>().add(PauseTimer());
                            } else {
                              context.read<PomodoroBloc>().add(StartTimer());
                            }
                          },
                          onReset: () {
                            context.read<PomodoroBloc>().add(ResetTimer());
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Jadwal Kuliah Hari Ini',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Courses Timeline List
              BlocBuilder<SchedulesBloc, SchedulesState>(
                builder: (context, state) {
                  if (state is SchedulesLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  } else if (state is SchedulesError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Gagal memuat jadwal: ${state.message}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    );
                  } else if (state is SchedulesLoaded) {
                    final effectiveCourses = _getEffectiveCourses(
                      state.courses,
                      state.reschedules,
                    );

                    if (effectiveCourses.isEmpty) {
                      return InteractiveEmptyState(
                        icon: Icons.coffee_rounded,
                        message:
                            'Hari Ini Bebas Kelas!\nTidak ada perkuliahan yang terjadwal untuk hari ini. Gunakan waktu luang Anda untuk belajar mandiri, bersantai, atau menyelesaikan tugas.',
                        actionLabel: 'Kelola Mata Kuliah',
                        actionIcon: Icons.book_rounded,
                        onActionPressed: () {
                          context
                              .findAncestorStateOfType<MainLayoutState>()
                              ?.setSelectedIndex(3);
                        },
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: effectiveCourses.length,
                      itemBuilder: (context, index) {
                        final ec = effectiveCourses[index];
                        final course = ec.course;
                        final displayStartTime =
                            ec.overrideStartTime ?? course.start_time;
                        final displayEndTime =
                            ec.overrideEndTime ?? course.end_time;
                        final isActive = _isClassActive(
                          displayStartTime,
                          displayEndTime,
                        );
                        final isPassed = _isClassPassed(displayEndTime);

                        return _buildTimelineItem(
                          course: course,
                          isCanceled: ec.isCanceled,
                          isRescheduled: ec.isRescheduled,
                          isReplacementClass: ec.isReplacementClass,
                          isActive: isActive,
                          isPassed: isPassed,
                          isFirst: index == 0,
                          isLast: index == effectiveCourses.length - 1,
                          overrideStartTime: ec.overrideStartTime,
                          overrideEndTime: ec.overrideEndTime,
                          originalDate: ec.originalDate,
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 32),

              // Today's Campus Events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Kegiatan Kampus Hari Ini',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<CampusEventsBloc, CampusEventsState>(
                builder: (context, state) {
                  if (state is CampusEventsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is CampusEventsLoaded) {
                    final todayStr = DateFormat(
                      'yyyy-MM-dd',
                    ).format(_currentTime);
                    final todayEvents = state.events
                        .where((e) => e.eventDate == todayStr)
                        .toList();

                    if (todayEvents.isEmpty) {
                      return InteractiveEmptyState(
                        icon: Icons.event_busy_rounded,
                        message: 'Tidak ada kegiatan kampus hari ini.',
                        actionLabel: 'Lihat Semua Kegiatan',
                        actionIcon: Icons.calendar_month,
                        onActionPressed: () {
                          context
                              .findAncestorStateOfType<MainLayoutState>()
                              ?.setSelectedIndex(9);
                        },
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayEvents.length,
                      itemBuilder: (context, index) {
                        final ev = todayEvents[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ev.eventName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Hari Ini',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${ev.startTime} - ${ev.endTime}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      ev.location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required CourseModel course,
    required bool isActive,
    required bool isPassed,
    required bool isFirst,
    required bool isLast,
    bool isCanceled = false,
    bool isRescheduled = false,
    bool isReplacementClass = false,
    String? overrideStartTime,
    String? overrideEndTime,
    String? originalDate,
  }) {
    final displayStartTime = overrideStartTime ?? course.start_time;
    final displayEndTime = overrideEndTime ?? course.end_time;

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
                // Top half of the line: from top of card to the dot center (draw for all except first item)
                if (!isFirst)
                  Positioned(
                    top: 0,
                    height: 31,
                    child: Container(
                      width: 2,
                      color: AppColors.outlineLight,
                    ),
                  ),
                // Bottom half of the line: from the dot center to bottom of card (draw for all except last item)
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
                      color: isActive
                          ? AppColors.primary
                          : (isPassed ? AppColors.secondary : Colors.white),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : (isPassed
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
                opacity: (isPassed || isCanceled || isRescheduled) ? 0.6 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.outlineLight,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
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
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textLightSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              if (isCanceled)
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
                              else if (isRescheduled)
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
                              else if (isReplacementClass)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.1),
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
                              if (isActive &&
                                  !isCanceled &&
                                  !isRescheduled) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
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
                        course.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLightPrimary,
                          decoration: (isPassed || isCanceled || isRescheduled)
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
                              course.lecturer,
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
                              course.room,
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
                      if (isActive && !isCanceled && !isRescheduled) ...[
                        const SizedBox(height: 16),
                        BlocBuilder<AttendanceBloc, AttendanceState>(
                          builder: (context, state) {
                            bool hasAttended = false;
                            if (state is AttendanceHistoryLoaded) {
                              final todayStr = DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.now());
                              hasAttended = state.records.any((record) {
                                return record['course_id'] == course.id &&
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
                                          courseId: course.id,
                                          courseCode: course.course_code,
                                          courseName: course.name,
                                        ),
                                  ),
                                ).then(
                                  (_) => _handleRefresh(),
                                ); // Refresh attendance on return
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
  }

  Widget _buildSmallBentoCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textLightPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTallPomodoroCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String timerValue,
    required String label,
    required bool isRunning,
    required VoidCallback onPlayPause,
    required VoidCallback onReset,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.textLightSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onReset,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  timerValue,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textLightPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPlayPause,
              icon: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 14,
                color: Colors.white,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isRunning ? 'Jeda' : 'Mulai',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to represent a course in the daily timeline with reschedule info
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
