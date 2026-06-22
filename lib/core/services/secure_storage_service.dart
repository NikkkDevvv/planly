import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'auth_token';
  static const String _faceKey = 'planly_registered_face';
  static const String _facePhotoKey = 'planly_registered_face_photo';
  static const String _geminiKey = 'planly_gemini_api_key';

  // Generic write
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Generic read
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Generic delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Gemini Key
  Future<void> saveGeminiApiKey(String apiKey) async {
    await write(_geminiKey, apiKey);
  }

  Future<String?> getGeminiApiKey() async {
    return await read(_geminiKey);
  }

  // Clear all storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Token Helpers
  Future<void> saveToken(String token) async {
    await write(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return await read(_tokenKey);
  }

  Future<void> deleteToken() async {
    await delete(_tokenKey);
  }

  // Face Descriptor Helpers
  Future<void> saveFaceDescriptor(String faceJson) async {
    await write(_faceKey, faceJson);
  }

  Future<String?> getFaceDescriptor() async {
    return await read(_faceKey);
  }

  Future<void> deleteFaceDescriptor() async {
    await delete(_faceKey);
  }

  // Face Photo Helpers
  Future<void> saveFacePhoto(String base64Photo) async {
    await write(_facePhotoKey, base64Photo);
  }

  Future<String?> getFacePhoto() async {
    return await read(_facePhotoKey);
  }

  Future<void> deleteFacePhoto() async {
    await delete(_facePhotoKey);
  }

  // Gemini API Key Helpers
  Future<void> saveGeminiKey(String key) async {
    await write(_geminiKey, key);
  }

  Future<String?> getGeminiKey() async {
    return await read(_geminiKey);
  }

  Future<void> deleteGeminiKey() async {
    await delete(_geminiKey);
  }
}
