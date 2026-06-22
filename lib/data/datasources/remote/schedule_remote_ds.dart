import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ScheduleRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getReschedules() async {
    return await _apiClient.dio.get('/reschedules');
  }

  Future<Response> createReschedule(Map<String, dynamic> rescheduleData) async {
    return await _apiClient.dio.post(
      '/reschedules',
      data: rescheduleData,
    );
  }

  Future<Response> deleteReschedule({
    required int courseId,
    required String originalDate,
  }) async {
    return await _apiClient.dio.delete('/reschedules/$courseId/$originalDate');
  }
}
