import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentInsightsScreen extends StatefulWidget {
  const StudentInsightsScreen({super.key});

  @override
  State<StudentInsightsScreen> createState() => _StudentInsightsScreenState();
}

class _StudentInsightsScreenState extends State<StudentInsightsScreen> {
  final _searchController = TextEditingController();
  bool showData = false;

  // Mock student data (replace with FastAPI response later)
  final Map<String, dynamic> studentData = {
    "name": "A. Karthik",
    "regNo": "VV2025CSE003",
    "dept": "Computer Science and Engineering",
    "cgpa": 8.92,
    "semesters": [8.3, 8.7, 9.0, 9.3],
    "subjects": {
      "Maths": 85,
      "DS": 90,
      "OOPS": 92,
      "DBMS": 88,
      "CN": 80,
    }
  };

  void handleSearch() {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Register Number")),
      );
      return;
    }
    // In real app: call API → fetch student data
    setState(() {
      showData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Insights"),
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Search Student",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Enter Register Number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: handleSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB11116),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: const Text("Search",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 📊 Student Info + Charts
            if (showData) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Student Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB11116),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Name: ${studentData['name']}"),
                    Text("Register No: ${studentData['regNo']}"),
                    Text("Department: ${studentData['dept']}"),
                    Text("CGPA: ${studentData['cgpa']}"),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                "Semester-wise GPA Trend",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final sem = ["S1", "S2", "S3", "S4"];
                            return Text(sem[value.toInt() % sem.length]);
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: const Color(0xFFB11116),
                        barWidth: 4,
                        spots: [
                          for (int i = 0;
                              i < studentData['semesters'].length;
                              i++)
                            FlSpot(i.toDouble(),
                                studentData['semesters'][i].toDouble())
                        ],
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFB11116).withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                "Subject-wise Marks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final subjects = studentData['subjects'].keys.toList();
                            return Text(subjects[value.toInt() % subjects.length]);
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (int i = 0;
                          i < studentData['subjects'].length;
                          i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: studentData['subjects']
                                    .values
                                    .elementAt(i)
                                    .toDouble(),
                            color: const Color(0xFFB11116),
                            width: 18,
                          ),
                        ])
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
