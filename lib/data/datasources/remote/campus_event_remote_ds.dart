import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class CampusEventRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getEvents() async {
    return await _apiClient.dio.get('/events');
  }

  Future<Response> createEvent(Map<String, dynamic> eventData) async {
    return await _apiClient.dio.post(
      '/events',
      data: eventData,
    );
  }

  Future<Response> updateEvent(int id, Map<String, dynamic> eventData) async {
    return await _apiClient.dio.put(
      '/events/$id',
      data: eventData,
    );
  }

  Future<Response> deleteEvent(int id) async {
    return await _apiClient.dio.delete('/events/$id');
  }
}
