import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;
  bool _open = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _sidebarTranslate = Tween<double>(begin: -sidebarWidth, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _contentTranslate = Tween<double>(begin: 0, end: sidebarWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  void _toggleSidebar() {
    if (_navigating) return;
    setState(() {
      _open = !_open;
      _open ? _controller.forward() : _controller.reverse();
    });
  }

  // ✅ Single-click navigation with sidebar auto-close AFTER redirect
  Future<void> _handleNavigation(String route) async {
    if (_navigating) return;
    _navigating = true;

    // Prevent reopening same route
    if (ModalRoute.of(context)?.settings.name == route) {
      await _controller.reverse();
      setState(() => _open = false);
      _navigating = false;
      return;
    }

    // Navigate instantly (first click)
    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }

    // Close sidebar smoothly after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await _controller.reverse();
        setState(() => _open = false);
      }
      _navigating = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: Color(0xFFB11116), size: 28),
                onPressed: _toggleSidebar,
                tooltip: 'Menu',
              ),
              const SizedBox(width: 10),
              const Text(
                'Welcome, Student 👋',
                style: TextStyle(
                  color: Color(0xFFB11116),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
          // ✅ MAIN CONTENT (behind)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(_contentTranslate.value, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Here’s your academic summary and quick actions:",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                _buildCard(
                                  title: 'My Results',
                                  description:
                                      'View your semester-wise marks and grades.',
                                  icon: Icons.grade_outlined,
                                  color: Colors.blue,
                                  route: '/studentResults',
                                ),
                                _buildCard(
                                  title: 'Analysis',
                                  description:
                                      'Check your performance trend and subject averages.',
                                  icon: Icons.analytics_outlined,
                                  color: Colors.orange,
                                  route: '/studentAnalysis',
                                ),
                                _buildCard(
                                  title: 'Profile',
                                  description:
                                      'View your personal details and logout safely.',
                                  icon: Icons.person_outline,
                                  color: Colors.green,
                                  route: '/studentProfile',
                                ),
                                _buildCard(
                                  title: 'College Notices',
                                  description:
                                      'Access official circulars and announcements.',
                                  icon: Icons.notifications_outlined,
                                  color: Colors.purple,
                                  route: '/collegeNoticesStudent',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ✅ OVERLAY (middle layer, below sidebar)
          IgnorePointer(
            ignoring: !_open,
            child: AnimatedOpacity(
              opacity: _open ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _toggleSidebar,
                child: Container(color: Colors.black26),
              ),
            ),
          ),

          // ✅ SIDEBAR (topmost layer, always clickable)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(_sidebarTranslate.value, 0),
                child: SizedBox(
                  width: sidebarWidth,
                  height: MediaQuery.of(context).size.height,
                  child: Sidebar(
                    role: 'student',
                    onNavigate: _handleNavigation,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Dashboard Card Widget
  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => _handleNavigation(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 260,
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(1, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
