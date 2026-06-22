import '../../../data/models/course_model.dart';

abstract class CoursesEvent {}

class FetchCourses extends CoursesEvent {}

class AddCourse extends CoursesEvent {
  final CourseModel course;
  AddCourse(this.course);
}

class UpdateCourse extends CoursesEvent {
  final CourseModel course;
  UpdateCourse(this.course);
}

class DeleteCourse extends CoursesEvent {
  final int id;
  DeleteCourse(this.id);
}
