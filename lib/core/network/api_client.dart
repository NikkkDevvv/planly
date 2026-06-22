import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/secure_storage_service.dart';
import '../utils/navigation_service.dart';
import '../../features/auth/screens/login_screen.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio dio;
  final SecureStorageService _secureStorageService = SecureStorageService();

  ApiClient._internal() : dio = Dio() {
    dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          final token = await _secureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await _secureStorageService.deleteToken();
            NavigationService.navigateToAndRemoveUntil(const LoginScreen());
          }
          return handler.next(error);
        },
      ),
    );

    // Logger
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
    ));
  }
}
