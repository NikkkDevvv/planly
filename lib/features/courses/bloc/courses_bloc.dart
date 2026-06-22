import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/course_repository.dart';
import 'courses_event.dart';
import 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final CourseRepository _courseRepository = CourseRepository();

  CoursesBloc() : super(CoursesInitial()) {
    on<FetchCourses>(_onFetchCourses);
    on<AddCourse>(_onAddCourse);
    on<UpdateCourse>(_onUpdateCourse);
    on<DeleteCourse>(_onDeleteCourse);
  }

  Future<void> _onFetchCourses(FetchCourses event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      final courses = await _courseRepository.getCourses();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> _onAddCourse(AddCourse event, Emitter<CoursesState> emit) async {
    try {
      await _courseRepository.createCourse(event.course);
      add(FetchCourses());
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> _onUpdateCourse(UpdateCourse event, Emitter<CoursesState> emit) async {
    try {
      await _courseRepository.updateCourse(event.course);
      add(FetchCourses());
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> _onDeleteCourse(DeleteCourse event, Emitter<CoursesState> emit) async {
    try {
      await _courseRepository.deleteCourse(event.id);
      add(FetchCourses());
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
