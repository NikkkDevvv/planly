import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class CourseRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getCourses() async {
    return await _apiClient.dio.get('/courses');
  }

  Future<Response> createCourse(Map<String, dynamic> courseData) async {
    return await _apiClient.dio.post(
      '/courses',
      data: courseData,
    );
  }

  Future<Response> updateCourse(int id, Map<String, dynamic> courseData) async {
    return await _apiClient.dio.put(
      '/courses/$id',
      data: courseData,
    );
  }

  Future<Response> deleteCourse(int id) async {
    return await _apiClient.dio.delete('/courses/$id');
  }
}
