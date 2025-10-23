import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ClassAnalysisScreen extends StatelessWidget {
  const ClassAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Performance Analysis"),
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overall Class Performance",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            // 🔸 Pie Chart — Pass vs Fail
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: 78,
                      title: "Pass 78%",
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: 22,
                      title: "Fail 22%",
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "Subject-wise Average Marks",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Bar Chart — Average Marks
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final subjects = ["Maths", "DS", "OOPS", "DBMS", "CN"];
                          return Text(
                            subjects[value.toInt() % subjects.length],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 82, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 76, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 88, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 91, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(toY: 79, color: const Color(0xFFB11116))
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "Top Performers",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                TopperCard(name: "A. Karthik", regNo: "VV2025CSE003", gpa: 9.3),
                TopperCard(name: "S. Meena", regNo: "VV2025CSE005", gpa: 9.2),
                TopperCard(name: "R. Aravind", regNo: "VV2025CSE008", gpa: 9.1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TopperCard extends StatelessWidget {
  final String name;
  final String regNo;
  final double gpa;

  const TopperCard({
    super.key,
    required this.name,
    required this.regNo,
    required this.gpa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.star, color: Color(0xFFB11116), size: 40),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            regNo,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            "GPA: $gpa",
            style: const TextStyle(
              color: Color(0xFFB11116),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
