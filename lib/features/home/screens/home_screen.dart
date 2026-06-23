import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/schedule_helper.dart';
import '../../../core/widgets/interactive_empty_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../schedules/bloc/schedules_bloc.dart';
import '../../schedules/bloc/schedules_event.dart';
import '../../schedules/bloc/schedules_state.dart';
import '../bloc/attendance_bloc.dart';
import '../../events/bloc/campus_events_bloc.dart';
import '../../events/bloc/campus_events_event.dart';
import '../../events/bloc/campus_events_state.dart';
import '../../navigation/screens/main_layout.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_bento_stats.dart';
import '../widgets/home_timeline.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

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
    _refreshAllBlocs();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _refreshAllBlocs() {
    context.read<CoursesBloc>().add(FetchCourses());
    context.read<TasksBloc>().add(FetchTasks());
    context.read<SchedulesBloc>().add(FetchSchedules());
    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
    context.read<CampusEventsBloc>().add(FetchCampusEvents());
  }

  Future<void> _handleRefresh() async {
    _refreshAllBlocs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: HomeAppBar(
        formattedClock: AppDateUtils.getFormattedClock(_currentTime),
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
              // Bento Stats Grid (Tasks, Classes, Pomodoro)
              const HomeBentoStats(),
              const SizedBox(height: 32),

              // Title Section: Daily Schedule
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
                    AppDateUtils.formatIndonesianDate(_currentTime),
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
                    final effectiveCourses = ScheduleHelper.getEffectiveCourses(
                      date: _currentTime,
                      courses: state.courses,
                      reschedules: state.reschedules,
                    );

                    return HomeTimeline(
                      effectiveCourses: effectiveCourses,
                      currentTime: _currentTime,
                      onRefresh: _handleRefresh,
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 32),

              // Today's Campus Events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
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
                    final todayStr = DateFormat('yyyy-MM-dd').format(_currentTime);
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      color: AppColors.primary.withValues(alpha: 0.1),
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
}
