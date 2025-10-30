// lib/screens/shared/notices_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  PlatformFile? _selectedFile;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

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
        setState(() => _isSidebarOpen = false);
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
      if (!mounted) return;
      await _controller.reverse();
      setState(() => _isSidebarOpen = false);
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
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
            style: TextStyle(
                color: Color(0xFFB11116), fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title")),
              const SizedBox(height: 10),
              TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 2),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile != null
                    ? _selectedFile!.name
                    : "Select PDF File"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _uploading
                ? null
                : () async {
                    Navigator.pop(context);
                    await _uploadNotice();
                  },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB11116)),
            child: _uploading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text("Upload"),
          ),
        ],
      ),
    );
  }

  /// Header updated to match other screens (gradient, centered title, dashboard circle)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20, bottom: 20), // restored original margins
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // restored original padding
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
                color: Color(0xFFB11116), size: 26),
            onPressed: _toggleSidebar,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "College Notices",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(50),
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
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFB11116),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.dashboard, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role.toLowerCase() == "admin";

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F2FF),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: _openUploadDialog,
                backgroundColor: const Color(0xFFB11116),
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text("Upload Notice",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              )
            : null,
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 8),
                          Text(
                            isAdmin
                                ? "Manage and upload official circulars and announcements."
                                : "View official circulars, updates, and important information.",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          if (notices.isEmpty)
                            const Center(
                                child: Text("No notices available.",
                                    style: TextStyle(color: Colors.black54)))
                          else
                            Column(
                              children: notices
                                  .map((n) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: _NoticeCard(
                                          title: n["title"]!,
                                          desc: n["desc"]!,
                                          file: n["file"]!,
                                          date: n["date"]!,
                                          onDownload: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Downloading ${n["file"]!}...")),
                                            );
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_sidebarTranslate.value, 0),
                  child: child,
                );
              },
              child: RepaintBoundary(
                child: SizedBox(
                  width: sidebarWidth,
                  height: MediaQuery.of(context).size.height,
                  child: Sidebar(
                    role: widget.role,
                    onNavigate: _handleSidebarNavigation,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    // Restored original sizing & padding exactly as before
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // original padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // border removed per your request
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
          Text(desc, style: const TextStyle(color: Colors.black87, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(color: Colors.black54)),
              TextButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download, size: 18, color: Colors.purple),
                label: const Text("Download", style: TextStyle(color: Colors.purple)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
