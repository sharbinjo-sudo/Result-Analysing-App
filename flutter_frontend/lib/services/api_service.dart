import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      // ✅ Flutter Web / Windows
      baseUrl: "http://127.0.0.1:8000/api/auth",

      // ✅ Android Emulator (use instead if needed)
      // baseUrl: "http://10.0.2.2:8000/api/auth",

      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  // ✅ LOGIN (DJANGO SIMPLEJWT)
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await _dio.post(
        '/login/',
        data: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        // 🔥 CRITICAL FIX FOR FLUTTER WEB
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception("Login failed");
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["detail"] ?? "Login error");
      } else {
        throw Exception("Connection error");
      }
    }
  }
}
