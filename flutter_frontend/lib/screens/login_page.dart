import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  // 🔹 Temporary fake credentials for testing
  final Map<String, Map<String, String>> _fakeUsers = {
    "student@vvcoe.com": {"password": "student123", "role": "student"},
    "staff@vvcoe.com": {"password": "staff123", "role": "staff"},
    "admin@vvcoe.com": {"password": "admin123", "role": "admin"},
  };

  Future<void> handleLogin() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _loading = true);

    // ✅ First check for fake credentials (local test mode)
    await Future.delayed(const Duration(seconds: 1)); // small delay for realism

    if (_fakeUsers.containsKey(_email.text) &&
        _fakeUsers[_email.text]!["password"] == _password.text) {
      final role = _fakeUsers[_email.text]!["role"]!;
      await SecureStorage.saveToken("fake_token_for_$role");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, $role!")),
      );

      setState(() => _loading = false);

      // Navigate to correct dashboard
      if (role == "student") {
        Navigator.pushReplacementNamed(context, '/studentDashboard');
      } else if (role == "staff") {
        Navigator.pushReplacementNamed(context, '/staffDashboard');
      } else if (role == "admin") {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      }
      return;
    }

    // 🔹 If not fake user → try real API
    final data = await ApiService.login(_email.text, _password.text);
    setState(() => _loading = false);

    if (data != null && data['access_token'] != null) {
      await SecureStorage.saveToken(data['access_token']);

      final role = data['role'] ?? 'unknown';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, $role!")),
      );

      if (role.toLowerCase() == "student") {
        Navigator.pushReplacementNamed(context, '/studentDashboard');
      } else if (["staff", "faculty", "hod", "principal"]
          .contains(role.toLowerCase())) {
        Navigator.pushReplacementNamed(context, '/staffDashboard');
      } else if (role.toLowerCase() == "admin") {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unauthorized user role")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11116),
        title: const Text(
          "V V College of Engineering",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              children: [
                Image.asset('assets/images/vvcoe_logo.jpg', height: 80),
                const SizedBox(height: 12),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11116),
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Color(0xFFB11116)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Color(0xFFB11116)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _loading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB11116),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
                const SizedBox(height: 20),

                // 🧩 Display test credentials
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Test Login Accounts:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB11116))),
                      SizedBox(height: 6),
                      Text("Student — student@vvcoe.com / student123"),
                      Text("Staff — staff@vvcoe.com / staff123"),
                      Text("Admin — admin@vvcoe.com / admin123"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
