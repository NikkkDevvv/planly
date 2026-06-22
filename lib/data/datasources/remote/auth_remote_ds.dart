import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Response> login(String email, String password) async {
    return await _apiClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String nim,
  }) async {
    return await _apiClient.dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'nim': nim,
      },
    );
  }

  Future<Response> logout() async {
    return await _apiClient.dio.post('/logout');
  }

  Future<Response> getProfile() async {
    return await _apiClient.dio.get('/profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> profileData) async {
    return await _apiClient.dio.post(
      '/profile/update',
      data: profileData,
    );
  }
}
