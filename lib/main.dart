import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:planly/core/theme/app_theme.dart';
import 'package:planly/core/utils/navigation_service.dart';
import 'package:planly/features/auth/bloc/auth_bloc.dart';
import 'package:planly/features/auth/bloc/auth_event.dart';
import 'package:planly/features/courses/bloc/courses_bloc.dart';
import 'package:planly/features/tasks/bloc/tasks_bloc.dart';
import 'package:planly/features/notes/bloc/notes_bloc.dart';
import 'package:planly/features/schedules/bloc/schedules_bloc.dart';
import 'package:planly/features/profile/bloc/profile_bloc.dart';
import 'package:planly/features/home/bloc/pomodoro_bloc.dart';
import 'package:planly/features/home/bloc/attendance_bloc.dart';
import 'package:planly/features/events/bloc/campus_events_bloc.dart';
import 'package:planly/features/splash/splash_screen.dart';
import 'package:toastification/toastification.dart'; // Added toastification

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  runApp(const PlanlyApp());
}

class PlanlyApp extends StatelessWidget {
  const PlanlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()..add(AppStarted())),
        BlocProvider<CoursesBloc>(create: (context) => CoursesBloc()),
        BlocProvider<TasksBloc>(create: (context) => TasksBloc()),
        BlocProvider<NotesBloc>(create: (context) => NotesBloc()),
        BlocProvider<SchedulesBloc>(create: (context) => SchedulesBloc()),
        BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
        BlocProvider<PomodoroBloc>(create: (context) => PomodoroBloc()),
        BlocProvider<AttendanceBloc>(create: (context) => AttendanceBloc()),
        BlocProvider<CampusEventsBloc>(create: (context) => CampusEventsBloc()),
      ],
      child: ToastificationWrapper(
        child: MaterialApp(
          title: 'Planly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          navigatorKey: NavigationService.navigatorKey,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}