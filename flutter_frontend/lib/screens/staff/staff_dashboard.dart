import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;
  bool _isOpen = false;
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
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  // ✅ Single-click navigation that auto-closes AFTER redirect
  Future<void> _handleSidebarNavigation(String route) async {
    if (_navigating) return;
    _navigating = true;

    // Prevent redundant route reload
    if (ModalRoute.of(context)?.settings.name == route) {
      await _controller.reverse();
      setState(() => _isOpen = false);
      _navigating = false;
      return;
    }

    // Navigate immediately
    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }

    // Sidebar closes after page transition
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await _controller.reverse();
        setState(() => _isOpen = false);
      }
      _navigating = false;
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
                "Welcome, Staff 👋",
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
          // ✅ MAIN CONTENT (at back)
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Manage class performance, upload results, and monitor student progress.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // ✅ Dashboard Cards
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                _buildCard(
                                  title: "Upload Results",
                                  icon: Icons.upload_file,
                                  color: Colors.green,
                                  description:
                                      "Upload marks or PDFs, or manually enter results.",
                                  route: '/staffUploadResults',
                                ),
                                _buildCard(
                                  title: "Class Analysis",
                                  icon: Icons.bar_chart_outlined,
                                  color: Colors.orange,
                                  description:
                                      "View class pass percentage, averages, and toppers.",
                                  route: '/staffClassAnalysis',
                                ),
                                _buildCard(
                                  title: "Student Insights",
                                  icon: Icons.people_outline,
                                  color: Colors.blue,
                                  description:
                                      "Search individual students and analyze performance.",
                                  route: '/staffStudentInsights',
                                ),
                                _buildCard(
                                  title: "College Notices",
                                  icon: Icons.notifications_outlined,
                                  color: Colors.purple,
                                  description:
                                      "View and download official circulars.",
                                  route: '/collegeNoticesStaff',
                                ),
                                _buildCard(
                                  title: "Profile",
                                  icon: Icons.person_outline,
                                  color: Colors.red,
                                  description:
                                      "View your profile details and logout safely.",
                                  route: '/staffProfile',
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

          // ✅ OVERLAY (middle layer)
          IgnorePointer(
            ignoring: !_isOpen,
            child: AnimatedOpacity(
              opacity: _isOpen ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _toggleSidebar,
                child: Container(color: Colors.black26),
              ),
            ),
          ),

          // ✅ SIDEBAR (topmost — always clickable)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(_sidebarTranslate.value, 0),
                child: SizedBox(
                  width: sidebarWidth,
                  height: MediaQuery.of(context).size.height,
                  child: Sidebar(
                    role: "staff",
                    onNavigate: _handleSidebarNavigation,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔸 Dashboard Card Widget
  Widget _buildCard({
    required String title,
    String? description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleSidebarNavigation(route),
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
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            if (description != null) ...[
  const SizedBox(height: 6),
  Text(
    description, // ✅ removed unnecessary !
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 13,
      color: Colors.black54,
      height: 1.3,
    ),
  ),
],

          ],
        ),
      ),
    );
  }
}
