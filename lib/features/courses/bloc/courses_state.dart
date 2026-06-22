import '../../../data/models/course_model.dart';

abstract class CoursesState {}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<CourseModel> courses;
  CoursesLoaded(this.courses);
}

class CoursesError extends CoursesState {
  final String message;
  CoursesError(this.message);
}
