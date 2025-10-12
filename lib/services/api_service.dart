import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';

  // 🔹 Old login kept intact — you can still use it for email-based logins
  static Future<Map<String, dynamic>?> login(
      String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Login failed: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  // 🔹 New helper login (for cases with no email — password + role only)
  static Future<Map<String, dynamic>?> loginWithPasswordOnly(
      String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Login (password-only) failed: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  // 🔹 Registration (unchanged)
  static Future<bool> register(
      String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Register failed: ${response.statusCode}');
      print(response.body);
      return false;
    }
  }
}