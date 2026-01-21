import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../services/api_service.dart';
import '../utils/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;

  Future<void> handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter username and password")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await ApiService.login(username, password);
      final accessToken = data["access"];

      await SecureStorage.saveToken(accessToken);

      final decodedToken = Jwt.parseJwt(accessToken);
      final role = decodedToken["role"];

      SecureStorage.setRole(role);

      setState(() => _loading = false);

      // 🔥 RESET STACK ON LOGIN
      if (role == "admin") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/adminDashboard",
          (_) => false,
        );
      } else if (role == "staff") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/staffDashboard",
          (_) => false,
        );
      } else if (role == "student") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/studentDashboard",
          (_) => false,
        );
      } else {
        await SecureStorage.deleteToken();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unauthorized role")),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;

    return WillPopScope(
      // ✅ Allow back button to CLOSE app (not navigate back)
      onWillPop: () async => true,
      child: Scaffold(
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
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB11116),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/vvcoe_logo.jpg',
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 20),

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
                    ),
                  ),

                  const SizedBox(height: 28),

                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFFB11116),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFFB11116),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.3,
                              ),
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Only authorized users can log in",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
