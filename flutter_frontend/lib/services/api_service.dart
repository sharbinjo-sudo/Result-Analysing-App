import 'dart:async';

import 'package:dio/dio.dart';

import '../utils/storage.dart';

class ApiService {
  ApiService._();

  static const String _defaultBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestPath = error.requestOptions.path;
          if (error.response?.statusCode == 401 && requestPath != '/auth/refresh/') {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final retryOptions = error.requestOptions;
              final token = await SecureStorage.getToken();
              retryOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(retryOptions);
              handler.resolve(response);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
  static Completer<bool>? _refreshCompleter;

  static Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await SecureStorage.clearSession();
      completer.complete(false);
      _refreshCompleter = null;
      return false;
    }

    try {
      final response = await _dio.post(
        '/auth/refresh/',
        options: Options(headers: {'Authorization': null}),
        data: {'refresh': refreshToken},
      );
      final access = response.data['access'] as String?;
      final refresh = (response.data['refresh'] as String?) ?? refreshToken;
      if (access == null) {
        completer.complete(false);
        return false;
      }
      await SecureStorage.saveSession(accessToken: access, refreshToken: refresh);
      completer.complete(true);
      return true;
    } catch (_) {
      await SecureStorage.clearSession();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        options: Options(headers: {'Authorization': null}),
        data: {'username': username, 'password': password},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    return _getMap('/auth/dashboard/');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return _getMap('/auth/me/');
  }

  static Future<List<dynamic>> getNotices() async {
    return _getList('/auth/notices/');
  }

  static Future<void> uploadNotice({
    required String title,
    required String description,
    String? fileName,
    List<int>? bytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        if (bytes != null && fileName != null)
          'attachment': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      await _dio.post('/auth/notices/', data: formData);
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static Future<Map<String, dynamic>> getMyResults() async {
    return _getMap('/auth/results/my/');
  }

  static Future<Map<String, dynamic>> getMyAnalysis() async {
    return _getMap('/auth/results/analysis/');
  }

  static Future<Map<String, dynamic>> uploadResults(
    List<Map<String, dynamic>> entries,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/results/upload/',
        data: {'entries': entries},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static Future<Map<String, dynamic>> getClassAnalysis() async {
    return _getMap('/auth/results/class-analysis/');
  }

  static Future<Map<String, dynamic>> getStudentInsights([String query = '']) async {
    return _getMap(
      '/auth/results/student-insights/',
      queryParameters: query.isEmpty ? null : {'q': query},
    );
  }

  static Future<List<dynamic>> getUsers() async {
    return _getList('/auth/users/');
  }

  static Future<void> createUser(Map<String, dynamic> payload) async {
    try {
      await _dio.post('/auth/users/', data: payload);
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static Future<void> updateUser(int id, Map<String, dynamic> payload) async {
    try {
      await _dio.patch('/auth/users/$id/', data: payload);
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/auth/users/$id/');
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static Future<Map<String, dynamic>> _getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static Future<List<dynamic>> _getList(String path) async {
    try {
      final response = await _dio.get(path);
      return List<dynamic>.from(response.data as List);
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  static String _extractError(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      if (data['detail'] is String) return data['detail'] as String;
      final values = data.values.toList();
      final firstValue = values.isNotEmpty ? values.first : null;
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }
      if (firstValue != null) return firstValue.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return 'Something went wrong while talking to the server.';
  }
}
