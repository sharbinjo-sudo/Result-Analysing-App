import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/sidebar.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
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
    if (_navigating) return;
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  Future<void> _handleSidebarNavigation(String route) async {
    if (_navigating) return;
    _navigating = true;

    if (ModalRoute.of(context)?.settings.name == route) {
      await _controller.reverse();
      setState(() => _isOpen = false);
      _navigating = false;
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await _controller.reverse();
        setState(() => _isOpen = false);
      }
      _navigating = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (_isOpen) {
      _toggleSidebar();
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          "Exit App?",
          style: TextStyle(
            color: Color(0xFFB11116),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text("Do you really want to close the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Exit",
              style: TextStyle(color: Color(0xFFB11116)),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) SystemNavigator.pop();
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ✅ Clean gradient header with perfect center alignment
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: Color(0xFFB11116), size: 30),
              onPressed: _toggleSidebar,
              tooltip: 'Menu',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Welcome, Student 👋",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/studentProfile'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFB11116),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x33B11116),
                        blurRadius: 8,
                        offset: Offset(0, 3))
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Clean white cards (adaptive)
  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleSidebarNavigation(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 260,
        height: 160,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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

  /// ✅ Main layout (adaptive for all screens)
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F2FF), // your chosen screen color
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 700;

                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Here’s your academic summary and quick actions:",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 24,
                                    runSpacing: 24,
                                    direction: isMobile
                                        ? Axis.vertical
                                        : Axis.horizontal,
                                    children: [
                                      _buildCard(
                                        title: "My Results",
                                        description:
                                            "View your semester-wise marks and grades.",
                                        icon: Icons.grade_outlined,
                                        color: Colors.blue,
                                        route: '/studentResults',
                                      ),
                                      _buildCard(
                                        title: "Analysis",
                                        description:
                                            "Check your performance trend and subject averages.",
                                        icon: Icons.analytics_outlined,
                                        color: Colors.orange,
                                        route: '/studentAnalysis',
                                      ),
                                      _buildCard(
                                        title: "Profile",
                                        description:
                                            "View your personal details and logout safely.",
                                        icon: Icons.person_outline,
                                        color: Colors.green,
                                        route: '/studentProfile',
                                      ),
                                      _buildCard(
                                        title: "College Notices",
                                        description:
                                            "Access official circulars and announcements.",
                                        icon: Icons.notifications_outlined,
                                        color: Colors.purple,
                                        route: '/collegeNoticesStudent',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // overlay
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

            // sidebar
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_sidebarTranslate.value, 0),
                  child: SizedBox(
                    width: sidebarWidth,
                    height: MediaQuery.of(context).size.height,
                    child: Sidebar(
                      role: "student",
                      onNavigate: _handleSidebarNavigation,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
