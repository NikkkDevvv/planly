import '../datasources/remote/course_remote_ds.dart';
import '../models/course_model.dart';

class CourseRepository {
  final CourseRemoteDataSource _remoteDataSource = CourseRemoteDataSource();

  Future<List<CourseModel>> getCourses() async {
    final response = await _remoteDataSource.getCourses();
    if (response.statusCode == 200) {
      final List<dynamic> list = response.data;
      return list.map((item) => CourseModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<CourseModel> createCourse(CourseModel course) async {
    final response = await _remoteDataSource.createCourse(course.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return CourseModel.fromJson(response.data);
    } else {
      throw Exception('Failed to create course');
    }
  }

  Future<CourseModel> updateCourse(CourseModel course) async {
    final response = await _remoteDataSource.updateCourse(course.id, course.toJson());
    if (response.statusCode == 200) {
      return CourseModel.fromJson(response.data);
    } else {
      throw Exception('Failed to update course');
    }
  }

  Future<void> deleteCourse(int id) async {
    final response = await _remoteDataSource.deleteCourse(id);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete course');
    }
  }
}
