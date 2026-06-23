import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/schedules_bloc.dart';
import '../bloc/schedules_event.dart';
import '../bloc/schedules_state.dart';
import '../../home/bloc/attendance_bloc.dart';
import 'schedule_form_screen.dart';
import '../widgets/schedule_stats_panel.dart';
import '../widgets/schedule_week_strip.dart';
import '../widgets/schedule_month_grid.dart';
import '../widgets/schedule_daily_timeline.dart';

class ScheduleScreens extends StatefulWidget {
  const ScheduleScreens({super.key});

  @override
  State<ScheduleScreens> createState() => _ScheduleScreensState();
}

class _ScheduleScreensState extends State<ScheduleScreens> {
  late List<DateTime> _weekDates;
  bool _isMonthView = false;
  DateTime _viewedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
    context.read<SchedulesBloc>().add(FetchSchedules());
    context.read<AttendanceBloc>().add(FetchAttendanceHistory());
  }

  void _generateWeekDates() {
    // Generates 7 days starting from today
    _weekDates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
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
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            color: AppColors.textLightPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Weekly vs Monthly Toggle Button
          IconButton(
            onPressed: () {
              setState(() {
                _isMonthView = !_isMonthView;
              });
            },
            icon: Icon(
              _isMonthView
                  ? Icons.view_week_outlined
                  : Icons.calendar_view_month_outlined,
              color: AppColors.primary,
            ),
            tooltip: _isMonthView ? 'Tampilan Mingguan' : 'Tampilan Bulanan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<SchedulesBloc, SchedulesState>(
        builder: (context, state) {
          if (state is SchedulesInitial || state is SchedulesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is SchedulesError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          } else if (state is SchedulesLoaded) {
            final courses = state.courses;
            final reschedules = state.reschedules;
            final selectedDate = state.selectedDate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Row
                ScheduleStatsPanel(courses: courses, reschedules: reschedules),

                // Calendar View section
                if (_isMonthView)
                  ScheduleMonthGrid(
                    viewedMonth: _viewedMonth,
                    selectedDate: selectedDate,
                    courses: courses,
                    onMonthChanged: (newMonth) {
                      setState(() {
                        _viewedMonth = newMonth;
                      });
                    },
                    onDateSelected: (newDate) {
                      context.read<SchedulesBloc>().add(SelectDate(newDate));
                      setState(() {
                        _isMonthView = false;
                      });
                    },
                  )
                else
                  ScheduleWeekStrip(
                    weekDates: _weekDates,
                    courses: courses,
                    selectedDate: selectedDate,
                    onDateSelected: (newDate) {
                      context.read<SchedulesBloc>().add(SelectDate(newDate));
                    },
                    onTodayPressed: () {
                      context.read<SchedulesBloc>().add(SelectDate(DateTime.now()));
                    },
                  ),

                const SizedBox(height: 16),

                // Selected date daily classes timeline list
                Expanded(
                  child: ScheduleDailyTimeline(
                    courses: courses,
                    reschedules: reschedules,
                    selectedDate: selectedDate,
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScheduleFormScreen()),
          ).then((value) {
            if (value == true) {
              context.read<SchedulesBloc>().add(FetchSchedules());
            }
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
