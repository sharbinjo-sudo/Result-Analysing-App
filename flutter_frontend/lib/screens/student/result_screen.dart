import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String selectedSemester = "Semester 1";

  // Temporary sample data (we’ll later replace this with FastAPI data)
  final Map<String, List<Map<String, dynamic>>> mockResults = {
    "Semester 1": [
      {"subject": "Mathematics I", "code": "MA101", "marks": 88, "grade": "A"},
      {"subject": "Physics", "code": "PH101", "marks": 76, "grade": "B+"},
      {"subject": "Programming", "code": "CS101", "marks": 91, "grade": "A+"},
      {"subject": "English", "code": "EN101", "marks": 83, "grade": "A"},
    ],
    "Semester 2": [
      {"subject": "Mathematics II", "code": "MA102", "marks": 81, "grade": "A"},
      {"subject": "Electronics", "code": "EC101", "marks": 74, "grade": "B"},
      {"subject": "Data Structures", "code": "CS102", "marks": 89, "grade": "A+"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentResults = mockResults[selectedSemester]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Results"),
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Semester Results",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            // Semester Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedSemester,
              items: mockResults.keys
                  .map(
                    (sem) => DropdownMenuItem(
                      value: sem,
                      child: Text(sem),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: "Select Semester",
                prefixIcon: Icon(Icons.school, color: Color(0xFFB11116)),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSemester = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Result Table
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFB11116),
                    ),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text("Subject")),
                      DataColumn(label: Text("Code")),
                      DataColumn(label: Text("Marks")),
                      DataColumn(label: Text("Grade")),
                    ],
                    rows: currentResults.map((res) {
                      return DataRow(
                        cells: [
                          DataCell(Text(res["subject"])),
                          DataCell(Text(res["code"])),
                          DataCell(Text(res["marks"].toString())),
                          DataCell(Text(res["grade"])),
                        ],
                      );
                    }).toList(),
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
