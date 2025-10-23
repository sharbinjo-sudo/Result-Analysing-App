import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Analysis"),
      ),
      backgroundColor: const Color(0xFFFFF8F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CGPA Trend by Semester",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Line Chart – CGPA Trend
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final semesters = ["S1", "S2", "S3", "S4"];
                          return Text(semesters[value.toInt() % semesters.length]);
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
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFB11116).withOpacity(0.2),
                      ),
                      spots: const [
                        FlSpot(0, 7.8),
                        FlSpot(1, 8.1),
                        FlSpot(2, 8.3),
                        FlSpot(3, 8.6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "Subject-wise Marks Comparison",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB11116),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Bar Chart – Subject Scores
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
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
                      BarChartRodData(
                        toY: 85,
                        color: const Color(0xFFB11116),
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                        toY: 92,
                        color: const Color(0xFFB11116),
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(
                        toY: 78,
                        color: const Color(0xFFB11116),
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(
                        toY: 88,
                        color: const Color(0xFFB11116),
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(
                        toY: 95,
                        color: const Color(0xFFB11116),
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
