import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AssignmentRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getTasks() async {
    return await _apiClient.dio.get('/tasks');
  }

  Future<Response> createTask(Map<String, dynamic> taskData) async {
    return await _apiClient.dio.post(
      '/tasks',
      data: taskData,
    );
  }

  Future<Response> finishTask(int id) async {
    return await _apiClient.dio.patch('/tasks/$id/finish');
  }

  Future<Response> updateTask(int id, Map<String, dynamic> taskData) async {
    return await _apiClient.dio.put(
      '/tasks/$id',
      data: taskData,
    );
  }

  Future<Response> deleteTask(int id) async {
    return await _apiClient.dio.delete('/tasks/$id');
  }
}
