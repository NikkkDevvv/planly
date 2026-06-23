import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/bento_stat_card.dart';
import '../../../core/utils/schedule_helper.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_state.dart';
import '../../schedules/bloc/schedules_bloc.dart';
import '../../schedules/bloc/schedules_state.dart';
import '../bloc/pomodoro_bloc.dart';
import 'home_pomodoro_card.dart';

class HomeBentoStats extends StatelessWidget {
  const HomeBentoStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  return BentoStatCard(
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
                    final effective = ScheduleHelper.getEffectiveCourses(
                      date: DateTime.now(),
                      courses: state.courses,
                      reschedules: state.reschedules,
                    );
                    todayCoursesCount = effective
                        .where(
                          (ec) => !ec.isCanceled && !ec.isRescheduled,
                        )
                        .length;
                  }
                  return BentoStatCard(
                    color: const Color(0xFFE6FDF4), // Soft emerald green
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
              return HomePomodoroCard(
                color: const Color(0xFFEEF2FF), // Soft indigo
                icon: state.isBreak
                    ? Icons.coffee_rounded
                    : Icons.local_fire_department_rounded,
                iconColor: const Color(0xFF6366F1),
                timerValue: state.formattedTime,
                label: state.isBreak ? 'Waktu Istirahat' : 'Fokus Pomodoro',
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
    );
  }
}
