import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../utils/storage.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
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

    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      await _controller.reverse();
      setState(() => _isOpen = false);
      _navigating = false;
      return;
    }

    if (route == '/login') {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } else {
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
    Navigator.pushReplacementNamed(context, '/adminDashboard');
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ Header with Dashboard Icon
  Widget _buildHeader() {
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
            IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: Color(0xFFB11116), size: 28),
              onPressed: _toggleSidebar,
              tooltip: 'Menu',
            ),
            const SizedBox(width: 8),
            const Text(
              "Admin Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const Spacer(),
            // ✅ Dashboard Icon
            Material(
              color: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/adminDashboard');
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB11116),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.dashboard,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Profile Card with Name + Logout
  Widget _buildProfileCard() {
    return Center(
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
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFB11116),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "Admin Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Added Name Field
            const ListTile(
              leading: Icon(Icons.person_outline, color: Color(0xFFB11116)),
              title: Text("Name"),
              subtitle: Text("N. R. Forename"),
            ),

            const ListTile(
              leading: Icon(Icons.email_outlined, color: Color(0xFFB11116)),
              title: Text("Email"),
              subtitle: Text("admin@vvcoe.com"),
            ),
            const ListTile(
              leading: Icon(Icons.work_outline, color: Color(0xFFB11116)),
              title: Text("Position"),
              subtitle: Text("System Administrator"),
            ),
            const ListTile(
              leading: Icon(Icons.security_outlined, color: Color(0xFFB11116)),
              title: Text("Privileges"),
              subtitle: Text("Full Access"),
            ),
            const SizedBox(height: 28),

            // ✅ Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                await SecureStorage.deleteToken();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (r) => false);
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB11116),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F8),
        body: Stack(
          children: [
            // Main content (slides when sidebar open)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      Expanded(child: _buildProfileCard()),
                    ],
                  ),
                );
              },
            ),

            // Overlay
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

            // Sidebar
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
      ),
    );
  }
}
