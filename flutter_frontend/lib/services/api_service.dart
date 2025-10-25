import 'package:dio/dio.dart';

class ApiService {
  // ✅ Create a single Dio instance with base options
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://your-api-url.com/api", // change this to your FastAPI URL later
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  // ✅ Login method returning a JSON Map or null
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          "email": email,
          "password": password,
        },
      );

      // Check for valid response
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        print("Login failed: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      // Dio-specific error handling
      if (e.response != null) {
        print("Login error: ${e.response?.data}");
      } else {
        print("Connection error: ${e.message}");
      }
      return null;
    } catch (e) {
      // Any other error
      print("Unexpected error: $e");
      return null;
    }
  }
}
