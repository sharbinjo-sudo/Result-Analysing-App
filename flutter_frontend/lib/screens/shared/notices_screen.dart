// lib/screens/shared/notices_screen.dart
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';

class NoticesScreen extends StatefulWidget {
  final String role; // "student", "staff", or "admin"
  const NoticesScreen({super.key, required this.role});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;

  bool _isSidebarOpen = false;
  bool _navigating = false;

  List<Map<String, String>> notices = [
    {
      "title": "End Semester Schedule",
      "desc": "End semester exam schedule for all departments.",
      "file": "end_sem_schedule.pdf",
      "date": "20 Oct 2025",
    },
    {
      "title": "Holiday Circular",
      "desc": "College closed on account of festival.",
      "file": "holiday_notice.pdf",
      "date": "14 Oct 2025",
    },
  ];

  bool _uploading = false;
  html.File? _selectedFile;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

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

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    if (_navigating) return;
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      _isSidebarOpen ? _controller.forward() : _controller.reverse();
    });
  }

  Future<void> _handleSidebarNavigation(String route) async {
    if (_navigating) return;
    _navigating = true;

    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      if (_isSidebarOpen) {
        await _controller.reverse();
        if (mounted) setState(() => _isSidebarOpen = false);
      }
      _navigating = false;
      return;
    }

    if (route == '/login') {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) {
        _navigating = false;
        return;
      }
      await _controller.reverse();
      if (mounted) setState(() => _isSidebarOpen = false);
      _navigating = false;
    });
  }

  Future<bool> _onWillPop() async {
    String dashboardRoute;
    switch (widget.role.toLowerCase()) {
      case "admin":
        dashboardRoute = '/adminDashboard';
        break;
      case "staff":
        dashboardRoute = '/staffDashboard';
        break;
      default:
        dashboardRoute = '/studentDashboard';
    }
    Navigator.pushReplacementNamed(context, dashboardRoute);
    return false;
  }

  void _pickFile() {
    final uploadInput = html.FileUploadInputElement()..accept = '.pdf';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) setState(() => _selectedFile = file);
    });
  }

  Future<void> _uploadNotice() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select a file.")),
      );
      return;
    }

    setState(() => _uploading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      notices.insert(0, {
        "title": _titleController.text,
        "desc": _descController.text,
        "file": _selectedFile!.name,
        "date": "Now",
      });
      _uploading = false;
      _selectedFile = null;
      _titleController.clear();
      _descController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notice uploaded successfully!")),
    );
  }

  Future<void> _openUploadDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Upload New Notice",
            style: TextStyle(color: Color(0xFFB11116), fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              const SizedBox(height: 10),
              TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 2),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile != null ? _selectedFile!.name : "Select PDF File"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _uploading
                ? null
                : () async {
                    Navigator.pop(context);
                    await _uploadNotice();
                  },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB11116)),
            child: _uploading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Upload"),
          ),
        ],
      ),
    );
  }

  // ✅ Updated Header (matches dashboard style)
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
              icon: const Icon(Icons.menu_rounded, color: Color(0xFFB11116), size: 28),
              onPressed: _toggleSidebar,
            ),
            const SizedBox(width: 8),
            const Text(
              "College Notices 📢",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const Spacer(),

            // ✅ Dashboard Icon (adaptive to role)
            Material(
              color: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  switch (widget.role.toLowerCase()) {
                    case "admin":
                      Navigator.pushReplacementNamed(context, '/adminDashboard');
                      break;
                    case "staff":
                      Navigator.pushReplacementNamed(context, '/staffDashboard');
                      break;
                    default:
                      Navigator.pushReplacementNamed(context, '/studentDashboard');
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB11116),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.dashboard, color: Colors.white, size: 22),
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
    final isAdmin = widget.role.toLowerCase() == "admin";

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F8),

        // ✅ Floating Upload Button (only for Admin)
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: _openUploadDialog,
                backgroundColor: const Color(0xFFB11116),
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text("Upload Notice",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              )
            : null,

        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        Text(
                          isAdmin
                              ? "Manage and upload official circulars and announcements."
                              : "View official circulars, updates, and important information.",
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        if (notices.isEmpty)
                          const Center(
                              child: Text("No notices available.",
                                  style: TextStyle(color: Colors.black54)))
                        else
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: notices.map((n) {
                              return _NoticeCard(
                                title: n["title"]!,
                                desc: n["desc"]!,
                                file: n["file"]!,
                                date: n["date"]!,
                                onDownload: () {
                                  html.AnchorElement(href: "#")
                                    ..setAttribute("download", n["file"]!)
                                    ..click();
                                },
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 80), // extra bottom padding for FAB
                      ],
                    ),
                  ),
                );
              },
            ),

            // Overlay
            IgnorePointer(
              ignoring: !_isSidebarOpen,
              child: AnimatedOpacity(
                opacity: _isSidebarOpen ? 1 : 0,
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
                    child: Sidebar(role: widget.role, onNavigate: _handleSidebarNavigation),
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

// 🔸 Notice Card Widget
class _NoticeCard extends StatelessWidget {
  final String title, desc, file, date;
  final VoidCallback? onDownload;

  const _NoticeCard({
    Key? key,
    required this.title,
    required this.desc,
    required this.file,
    required this.date,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB11116).withOpacity(0.3)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116))),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(color: Colors.black54)),
              TextButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Download"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
