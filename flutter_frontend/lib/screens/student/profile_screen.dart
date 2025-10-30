import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../utils/storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;
  bool _isOpen = false;
  bool _navigating = false;

  final Map<String, String> studentData = const {
    "name": "N. R. Hacker",
    "registerNo": "VV2025CSE001",
    "department": "Artificial Intelligence and Data Science",
    "email": "student@vvcoe.com",
    "role": "Student",
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
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

    if (mounted) Navigator.pushReplacementNamed(context, route);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 250));
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

  /// ✅ Header
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
            const Expanded(
              child: Text(
                "Student Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/studentDashboard', (route) => false);
              },
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
                child: const Icon(Icons.dashboard, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Adaptive Profile Card
  Widget _buildProfileCard(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;
    final double cardWidth = isMobile ? constraints.maxWidth - 40 : 400;

    final profileCard = Container(
      padding: const EdgeInsets.all(24),
      width: cardWidth,
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
            "Student Profile",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB11116),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFFB11116)),
            title: const Text("Name"),
            subtitle: Text(studentData["name"]!),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined, color: Color(0xFFB11116)),
            title: const Text("Register Number"),
            subtitle: Text(studentData["registerNo"]!),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined, color: Color(0xFFB11116)),
            title: const Text("Department"),
            subtitle: Text(studentData["department"]!),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: Color(0xFFB11116)),
            title: const Text("Email"),
            subtitle: Text(studentData["email"]!),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline, color: Color(0xFFB11116)),
            title: const Text("Role"),
            subtitle: Text(studentData["role"]!),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Logout"),
                    content: const Text(
                        "Are you sure you want to logout from your account?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB11116),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );

                if (confirmLogout == true) {
                  await SecureStorage.deleteToken();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  }
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
          ),
        ],
      ),
    );

    // ✅ Allow scroll only if needed
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 0,
        vertical: isMobile ? 20 : 30,
      ),
      child: Center(child: profileCard),
    );
  }

  /// ✅ Build
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/studentDashboard',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F2FF),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          _buildHeader(),
                          Expanded(child: _buildProfileCard(constraints)),
                        ],
                      );
                    },
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
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_sidebarTranslate.value, 0),
                  child: child,
                );
              },
              child: SizedBox(
                width: sidebarWidth,
                height: MediaQuery.of(context).size.height,
                child: Sidebar(
                  role: "student",
                  onNavigate: _handleSidebarNavigation,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
