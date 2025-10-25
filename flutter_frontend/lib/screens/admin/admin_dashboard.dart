import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
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

  // ✅ Single-click navigation with delayed sidebar close
  Future<void> _handleSidebarNavigation(String route) async {
    if (_navigating) return;
    _navigating = true;

    if (ModalRoute.of(context)?.settings.name == route) {
      await _controller.reverse();
      setState(() => _isOpen = false);
      _navigating = false;
      return;
    }

    // Navigate first for instant feedback
    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }

    // Close sidebar after transition
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

  // ---------- Header now matches Notices style: boxed card with rounded corners ----------
  Widget _buildHeader() {
    // We add a horizontal margin so the header looks like a card inside the page (like Notices).
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Left: menu + title
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFFB11116),
                    size: 28,
                  ),
                  onPressed: _toggleSidebar,
                  tooltip: 'Menu',
                ),
                const SizedBox(width: 8),
                const Text(
                  "Welcome, Admin 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11116),
                  ),
                ),
              ],
            ),

            // spacer
            const Spacer(),

            // Right: avatar-like circular button (styled to match Notices' right-side control)
            Material(
              color: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // keep empty for now (you can put profile/notifications here)
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB11116),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      body: Stack(
        children: [
          // ✅ MAIN CONTENT
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(_contentTranslate.value, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    // Add a small gap under the header to visually match Notices layout
                    const SizedBox(height: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Manage users, approve accounts, and control notices.",
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                _buildCard(
                                  title: "Manage Notices",
                                  description:
                                      "Upload or remove official college notices.",
                                  icon: Icons.notifications_active_outlined,
                                  color: Colors.purple,
                                  route: '/collegeNoticesAdmin',
                                ),
                                _buildCard(
                                  title: "User Management",
                                  description:
                                      "Approve, revoke or delete user accounts.",
                                  icon: Icons.people_alt_outlined,
                                  color: Colors.blue,
                                  route: '/adminUserManagement',
                                ),
                                _buildCard(
                                  title: "Profile",
                                  description:
                                      "View your profile and logout safely.",
                                  icon: Icons.person_outline,
                                  color: Colors.red,
                                  route: '/adminProfile',
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

          // ✅ OVERLAY (tap to close)
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

          // ✅ SIDEBAR (top layer)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(_sidebarTranslate.value, 0),
                child: SizedBox(
                  width: sidebarWidth,
                  height: MediaQuery.of(context).size.height,
                  child: Sidebar(
                    role: "admin",
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

  // 🔹 Dashboard Card
  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => _handleSidebarNavigation(route),
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
