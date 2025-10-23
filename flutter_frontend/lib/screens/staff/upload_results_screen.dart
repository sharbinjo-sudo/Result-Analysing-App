import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadResultsScreen extends StatefulWidget {
  const UploadResultsScreen({super.key});

  @override
  State<UploadResultsScreen> createState() => _UploadResultsScreenState();
}

class _UploadResultsScreenState extends State<UploadResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  File? selectedFile;
  String? fileType;

  // For manual entry
  final List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ----------------------- File Upload -----------------------
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
            "Uploaded ${fileType?.toUpperCase()} successfully: ${selectedFile!.path.split('/').last}"),
      ),
    );

    setState(() {
      selectedFile = null;
      fileType = null;
    });
  }

  // ----------------------- Manual Entry -----------------------
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
    setState(() {
      entries.removeAt(index);
    });
  }

  void saveEntries() {
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No entries to save.")),
      );
      return;
    }

    // TODO: connect to FastAPI later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved ${entries.length} manual entries.")),
    );

    setState(() {
      entries.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload / Enter Results"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.upload_file), text: "Upload File"),
            Tab(icon: Icon(Icons.edit_note), text: "Manual Entry"),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: TabBarView(
        controller: _tabController,
        children: [
          // -------------------- Upload Tab --------------------
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload Result Files",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11116),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => pickFile("csv"),
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text("Upload CSV / Excel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB11116),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => pickFile("pdf"),
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text("Upload PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB11116),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (selectedFile != null)
                  Card(
                    color: Colors.white,
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
                    icon: const Icon(Icons.cloud_upload, color: Colors.white),
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

          // -------------------- Manual Entry Tab --------------------
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Results Manually",
                  style: TextStyle(
                    fontSize: 24,
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

                // ➕ Add Entry Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: addEntry,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add Entry",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB11116),
                      minimumSize: const Size(180, 48),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 💾 Save Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: saveEntries,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Save All Entries",
                      style: TextStyle(color: Colors.white),
                    ),
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
    );
  }
}
