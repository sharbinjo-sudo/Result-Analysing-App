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
  bool _showPassword = false;

  // Temporary fake credentials for testing
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
    await Future.delayed(const Duration(milliseconds: 800)); // realism

    // Local test login
    if (_fakeUsers.containsKey(_email.text) &&
        _fakeUsers[_email.text]!["password"] == _password.text) {
      final role = _fakeUsers[_email.text]!["role"]!;
      await SecureStorage.saveToken("fake_token_for_$role");
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, $role!")),
      );

      if (role == "student") {
        Navigator.pushReplacementNamed(context, '/studentDashboard');
      } else if (role == "staff") {
        Navigator.pushReplacementNamed(context, '/staffDashboard');
      } else if (role == "admin") {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      }
      return;
    }

    // Real API login
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
    final isSmall = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFE9F2FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: isSmall ? double.infinity : 400,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB11116), width: 2),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/vvcoe_logo.jpg',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                // College name
                const Text(
                  "V V College of Engineering",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11116),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Result Analysis System",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 28),

                // Email
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFFB11116)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _password,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Color(0xFFB11116)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB11116),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.3),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Test Accounts",
                          style: TextStyle(
                              color: Colors.black54, fontSize: 13.5)),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 10),

                // Test accounts
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Student — student@vvcoe.com / student123"),
                      Text("Staff — staff@vvcoe.com / staff123"),
                      Text("Admin — admin@vvcoe.com / admin123"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Only authorized users can log in",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
