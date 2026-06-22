import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class NoteRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getNotes() async {
    return await _apiClient.dio.get('/notes');
  }

  Future<Response> createNote(Map<String, dynamic> noteData) async {
    return await _apiClient.dio.post(
      '/notes',
      data: noteData,
    );
  }

  Future<Response> updateNote(int id, Map<String, dynamic> noteData) async {
    return await _apiClient.dio.put(
      '/notes/$id',
      data: noteData,
    );
  }

  Future<Response> deleteNote(int id) async {
    return await _apiClient.dio.delete('/notes/$id');
  }
}
