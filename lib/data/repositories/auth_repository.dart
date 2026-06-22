import 'dart:convert';
import '../datasources/remote/auth_remote_ds.dart';
import '../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSource();
  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<UserModel> login(String email, String password) async {
    final response = await _remoteDataSource.login(email, password);
    if (response.statusCode == 200) {
      final data = response.data;
      final String token = data['token'] ?? data['access_token'] ?? '';
      
      if (token.isNotEmpty) {
        await _secureStorageService.saveToken(token);
      }
      
      final userData = data['user'];
      return UserModel.fromJson(userData);
    } else {
      throw Exception(response.data['message'] ?? 'Login failed');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String nim,
  }) async {
    final response = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      nim: nim,
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _secureStorageService.deleteToken();
    }
  }

  Future<UserModel> getProfile() async {
    final response = await _remoteDataSource.getProfile();
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<UserModel> updateProfile(UserModel user) async {
    final response = await _remoteDataSource.updateProfile(user.toJson());
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
