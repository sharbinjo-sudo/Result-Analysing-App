import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late AnimationController _controller;
  late Animation<double> _sidebarTranslate;
  late Animation<double> _contentTranslate;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sidebarTranslate = Tween<double>(begin: -sidebarWidth, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _contentTranslate = Tween<double>(begin: 0, end: sidebarWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleSidebarNavigation(String route) {
    _toggleSidebar();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (ModalRoute.of(context)?.settings.name != route) {
        if (route == '/login') {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFFB11116),
                  size: 28,
                ),
                onPressed: _toggleSidebar,
              ),
              const SizedBox(width: 10),
              const Text(
                "Staff Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFB11116),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      body: Stack(
        children: [
          // 🔹 Sidebar
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(_sidebarTranslate.value, 0),
                child: Material(
                  elevation: 12,
                  color: const Color(0xFFB11116),
                  child: SizedBox(
                    width: sidebarWidth,
                    height: MediaQuery.of(context).size.height,
                    child: Sidebar(
                      role: "staff",
                      onNavigate: _handleSidebarNavigation,
                    ),
                  ),
                ),
              );
            },
          ),

          // 🔹 Page Content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(_contentTranslate.value, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          width: 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Color(0xFFB11116),
                                child: Icon(Icons.person,
                                    size: 40, color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Staff Profile",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB11116),
                                ),
                              ),
                              SizedBox(height: 12),
                              ListTile(
                                leading: Icon(Icons.email_outlined),
                                title: Text("Email"),
                                subtitle: Text("staff@vvcoe.com"),
                              ),
                              ListTile(
                                leading: Icon(Icons.school_outlined),
                                title: Text("Department"),
                                subtitle:
                                    Text("Computer Science and Engineering"),
                              ),
                              ListTile(
                                leading: Icon(Icons.badge_outlined),
                                title: Text("Role"),
                                subtitle: Text("Faculty"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🔹 Overlay for closing
          if (_isOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(
                color: Colors.black26,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
        ],
      ),
    );
  }
}
