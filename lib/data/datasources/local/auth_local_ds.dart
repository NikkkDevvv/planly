import '../../../core/services/secure_storage_service.dart';

class AuthLocalDataSource {
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<void> saveToken(String token) async {
    await _secureStorage.saveToken(token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  Future<void> deleteToken() async {
    await _secureStorage.deleteToken();
  }

  Future<void> clearAll() async {
    await _secureStorage.clearAll();
  }
}
