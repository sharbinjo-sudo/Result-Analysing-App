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

  Future<void> _logout() async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content:
            const Text("Are you sure you want to logout from your account?"),
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

    if (confirmLogout == true && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ Header (centered + consistent)
  Widget _buildHeader(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, isMobile ? 12 : 16, 20, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
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
            Expanded(
              child: Center(
                child: Text(
                  "Staff Profile",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11116),
                  ),
                ),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/staffDashboard',
                  (route) => false,
                );
              },
              child: Container(
                width: 44,
                height: 44,
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

  // ✅ Updated Profile Card (size/alignment matches student profile)
  Widget _buildProfileCard(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;
    final double cardWidth = isMobile ? constraints.maxWidth - 40 : 400;

    return Align(
      alignment: isMobile ? Alignment.topCenter : Alignment.center,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 0,
          vertical: isMobile ? 20 : 30,
        ),
        child: Container(
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
                "Staff Profile",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Staff Details
              const ListTile(
                leading: Icon(Icons.person_outline, color: Color(0xFFB11116)),
                title: Text("Name"),
                subtitle: Text("S. Meena"),
              ),
              const ListTile(
                leading: Icon(Icons.badge_outlined, color: Color(0xFFB11116)),
                title: Text("Faculty No."),
                subtitle: Text("FAC2025AI004"), // ✅ Added Faculty Number
              ),
              const ListTile(
                leading: Icon(Icons.email_outlined, color: Color(0xFFB11116)),
                title: Text("Email"),
                subtitle: Text("staff@vvcoe.com"),
              ),
              const ListTile(
                leading: Icon(Icons.school_outlined, color: Color(0xFFB11116)),
                title: Text("Department"),
                subtitle: Text("Artificial Intelligence and Data Science"),
              ),
              const ListTile(
                leading: Icon(Icons.work_outline, color: Color(0xFFB11116)),
                title: Text("Role"),
                subtitle: Text("Faculty"),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _logout,
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
      ),
    );
  }

  // ✅ Build UI
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/staffDashboard',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(constraints),
                          const SizedBox(height: 8),
                          Expanded(child: _buildProfileCard(constraints)),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
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
                  role: "staff",
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
