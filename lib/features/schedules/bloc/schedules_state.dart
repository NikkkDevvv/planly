import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';

abstract class SchedulesState {}

class SchedulesInitial extends SchedulesState {}

class SchedulesLoading extends SchedulesState {}

class SchedulesLoaded extends SchedulesState {
  final List<CourseModel> courses;
  final List<ScheduleModel> reschedules;
  final DateTime selectedDate;

  SchedulesLoaded({
    required this.courses,
    required this.reschedules,
    required this.selectedDate,
  });
}

class SchedulesError extends SchedulesState {
  final String message;
  SchedulesError(this.message);
}
