import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

class UploadResultsScreen extends StatefulWidget {
  const UploadResultsScreen({super.key});

  @override
  State<UploadResultsScreen> createState() => _UploadResultsScreenState();
}

class _UploadResultsScreenState extends State<UploadResultsScreen> {
  final List<_ResultEntryControllers> _rows = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(_ResultEntryControllers());
    });
  }

  void _removeRow(int index) {
    final row = _rows.removeAt(index);
    row.dispose();
    setState(() {});
  }

  Future<void> _saveEntries() async {
    final entries = <Map<String, dynamic>>[];
    for (final row in _rows) {
      final studentIdentifier = row.studentIdentifier.text.trim();
      final semester = int.tryParse(row.semester.text.trim());
      final marks = int.tryParse(row.marks.text.trim());
      final credits = double.tryParse(row.credits.text.trim());
      if (studentIdentifier.isEmpty ||
          semester == null ||
          row.subjectCode.text.trim().isEmpty ||
          row.subjectName.text.trim().isEmpty ||
          marks == null ||
          row.grade.text.trim().isEmpty ||
          credits == null) {
        _showMessage('Fill all fields before saving.');
        return;
      }
      if (semester < 1 || semester > 12) {
        _showMessage('Semester must be between 1 and 12.');
        return;
      }
      if (marks < 0 || marks > 100) {
        _showMessage('Marks must be between 0 and 100.');
        return;
      }

      entries.add({
        'student_identifier': studentIdentifier,
        'semester': semester,
        'subject_code': row.subjectCode.text.trim(),
        'subject_name': row.subjectName.text.trim(),
        'marks': marks,
        'grade': row.grade.text.trim(),
        'credits': credits,
      });
    }

    setState(() => _saving = true);
    try {
      final response = await ApiService.uploadResults(entries);
      _showMessage(response['message']?.toString() ?? 'Results saved.');
      for (final row in _rows) {
        row.clear();
      }
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'Upload Results',
      role: 'staff',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const DashboardHero(
            title: 'Manual Result Entry',
            subtitle:
                'Save marks directly to the backend. Student result pages, analysis charts, class insights, and staff dashboards all refresh from the same database records.',
            badges: [
              'DB-backed marks',
              'Student sync enabled',
              'Class analytics ready',
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Result Rows',
            subtitle:
                'Use the student register number or username. Semester, credits, marks, subject, and grade are entered by staff and saved as database values.',
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < _rows.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Entry ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_rows.length > 1)
                          IconButton(
                            onPressed: () => _removeRow(i),
                            icon: const Icon(Icons.delete_outline),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _FieldBox(
                          width: 220,
                          child: TextField(
                            controller: _rows[i].studentIdentifier,
                            decoration: const InputDecoration(
                              labelText: 'Register No / Username',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _FieldBox(
                          width: 120,
                          child: TextField(
                            controller: _rows[i].semester,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Semester',
                              hintText: '1-12',
                            ),
                          ),
                        ),
                        _FieldBox(
                          width: 160,
                          child: TextField(
                            controller: _rows[i].subjectCode,
                            decoration: const InputDecoration(
                              labelText: 'Subject Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _FieldBox(
                          width: 260,
                          child: TextField(
                            controller: _rows[i].subjectName,
                            decoration: const InputDecoration(
                              labelText: 'Subject Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _FieldBox(
                          width: 120,
                          child: TextField(
                            controller: _rows[i].marks,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Marks',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _FieldBox(
                          width: 120,
                          child: TextField(
                            controller: _rows[i].grade,
                            decoration: const InputDecoration(
                              labelText: 'Grade',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _FieldBox(
                          width: 120,
                          child: TextField(
                            controller: _rows[i].credits,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Credits',
                              hintText: 'Example: 3.0',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add),
                label: const Text('Add Row'),
              ),
              FilledButton.icon(
                onPressed: _saving ? null : _saveEntries,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save Entries'),
                style: FilledButton.styleFrom(backgroundColor: kPrimaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _ResultEntryControllers {
  _ResultEntryControllers();

  final TextEditingController studentIdentifier = TextEditingController();
  final TextEditingController semester = TextEditingController();
  final TextEditingController subjectCode = TextEditingController();
  final TextEditingController subjectName = TextEditingController();
  final TextEditingController marks = TextEditingController();
  final TextEditingController grade = TextEditingController();
  final TextEditingController credits = TextEditingController();

  void clear() {
    studentIdentifier.clear();
    semester.clear();
    subjectCode.clear();
    subjectName.clear();
    marks.clear();
    grade.clear();
    credits.clear();
  }

  void dispose() {
    studentIdentifier.dispose();
    semester.dispose();
    subjectCode.dispose();
    subjectName.dispose();
    marks.dispose();
    grade.dispose();
    credits.dispose();
  }
}
