import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../widgets/sidebar.dart';

class UploadResultsScreen extends StatefulWidget {
  const UploadResultsScreen({super.key});

  @override
  State<UploadResultsScreen> createState() => _UploadResultsScreenState();
}

class _UploadResultsScreenState extends State<UploadResultsScreen>
    with TickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;
  late final TabController _tabController;
  bool _isOpen = false;
  bool _navigating = false;

  File? selectedFile;
  String? fileType;
  final List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _sidebarTranslate = Tween<double>(begin: -sidebarWidth, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _contentTranslate = Tween<double>(begin: 0, end: sidebarWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _tabController = TabController(length: 2, vsync: this);
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

  // -------------------- File Picker --------------------
  Future<void> pickFile(String type) async {
    FilePickerResult? result;
    if (type == "pdf") {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );
    }

    if (result != null) {
      final path = result.files.single.path;
      if (path != null) {
        setState(() {
          selectedFile = File(path);
          fileType = type;
        });
      }
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file first.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Uploaded ${fileType?.toUpperCase()} successfully: ${selectedFile!.path.split('/').last}",
        ),
      ),
    );

    setState(() {
      selectedFile = null;
      fileType = null;
    });
  }

  // -------------------- Manual Entry --------------------
  void addEntry() {
    setState(() {
      entries.add({
        "regNo": "",
        "subject": "",
        "marks": "",
        "grade": "",
      });
    });
  }

  void removeEntry(int index) {
    setState(() => entries.removeAt(index));
  }

  void saveEntries() {
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No entries to save.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved ${entries.length} manual entries.")),
    );

    setState(() => entries.clear());
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Header (center-aligned)
  Widget _buildHeader(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "Upload / Enter Results",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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

  // ✅ Perfectly Aligned Buttons
  Widget _buildUploadButtons(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;
    final double buttonWidth =
        isMobile ? (constraints.maxWidth - 56) / 2 : 200; // Equal width buttons

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton.icon(
            onPressed: () => pickFile("csv"),
            icon: const Icon(Icons.upload_file, color: Colors.white, size: 22),
            label: const Text("Upload CSV / Excel"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB11116),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton.icon(
            onPressed: () => pickFile("pdf"),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 22),
            label: const Text("Upload PDF"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB11116),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Main Content
  Widget _buildContent(BoxConstraints constraints) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFB11116),
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xFFB11116),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(icon: Icon(Icons.upload_file), text: "Upload File"),
              Tab(icon: Icon(Icons.edit_note), text: "Manual Entry"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // -------------------- Upload Tab --------------------
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Upload Result Files",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB11116),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildUploadButtons(constraints),
                      const SizedBox(height: 28),
                      if (selectedFile != null)
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Icon(
                              fileType == "pdf"
                                  ? Icons.picture_as_pdf
                                  : Icons.table_chart,
                              color: fileType == "pdf"
                                  ? Colors.red
                                  : const Color(0xFFB11116),
                              size: 36,
                            ),
                            title: Text(selectedFile!.path.split('/').last),
                            subtitle: Text(fileType == "pdf"
                                ? "PDF Document"
                                : "CSV/Excel Data File"),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  selectedFile = null;
                                  fileType = null;
                                });
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: uploadFile,
                          icon: const Icon(Icons.cloud_upload,
                              color: Colors.white),
                          label: const Text(
                            "Upload",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB11116),
                            minimumSize: const Size(160, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // -------------------- Manual Entry Tab --------------------
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Results Manually",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB11116),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: "Register No",
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (v) =>
                                              entries[index]["regNo"] = v,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: "Subject",
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (v) =>
                                              entries[index]["subject"] = v,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: "Marks",
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (v) =>
                                              entries[index]["marks"] = v,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: "Grade",
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (v) =>
                                              entries[index]["grade"] = v,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => removeEntry(index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: addEntry,
                        icon:
                            const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Entry",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB11116),
                          minimumSize: const Size(180, 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: saveEntries,
                        icon:
                            const Icon(Icons.save, color: Colors.white),
                        label: const Text("Save All Entries",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB11116),
                          minimumSize: const Size(200, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ Build
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(_contentTranslate.value, 0),
                      child: Column(
                        children: [
                          _buildHeader(constraints),
                          const SizedBox(height: 12),
                          Expanded(child: _buildContent(constraints)),
                        ],
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
            );
          },
        ),
      ),
    );
  }
}
