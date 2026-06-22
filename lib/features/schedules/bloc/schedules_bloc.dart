import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import 'schedules_event.dart';
import 'schedules_state.dart';

class SchedulesBloc extends Bloc<SchedulesEvent, SchedulesState> {
  final CourseRepository _courseRepository = CourseRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  SchedulesBloc() : super(SchedulesInitial()) {
    on<FetchSchedules>(_onFetchSchedules);
    on<SelectDate>(_onSelectDate);
    on<AddReschedule>(_onAddReschedule);
    on<RemoveReschedule>(_onRemoveReschedule);
  }

  Future<void> _onFetchSchedules(FetchSchedules event, Emitter<SchedulesState> emit) async {
    final DateTime currentDate = state is SchedulesLoaded 
        ? (state as SchedulesLoaded).selectedDate 
        : DateTime.now();

    emit(SchedulesLoading());
    try {
      late List<CourseModel> courses;
      late List<ScheduleModel> reschedules;

      await Future.wait([
        _courseRepository.getCourses().then((v) => courses = v),
        _scheduleRepository.getReschedules().then((v) => reschedules = v),
      ]);

      emit(SchedulesLoaded(
        courses: courses,
        reschedules: reschedules,
        selectedDate: currentDate,
      ));
    } catch (e) {
      emit(SchedulesError(e.toString()));
    }
  }

  void _onSelectDate(SelectDate event, Emitter<SchedulesState> emit) {
    if (state is SchedulesLoaded) {
      final currentState = state as SchedulesLoaded;
      emit(SchedulesLoaded(
        courses: currentState.courses,
        reschedules: currentState.reschedules,
        selectedDate: event.selectedDate,
      ));
    }
  }

  Future<void> _onAddReschedule(AddReschedule event, Emitter<SchedulesState> emit) async {
    try {
      await _scheduleRepository.createReschedule(event.reschedule);
      add(FetchSchedules());
    } catch (e) {
      emit(SchedulesError(e.toString()));
    }
  }

  Future<void> _onRemoveReschedule(RemoveReschedule event, Emitter<SchedulesState> emit) async {
    try {
      await _scheduleRepository.deleteReschedule(event.courseId, event.originalDate);
      add(FetchSchedules());
    } catch (e) {
      emit(SchedulesError(e.toString()));
    }
  }
}
