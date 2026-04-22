import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

bool _isAxisIndex(double value) {
  return (value - value.roundToDouble()).abs() < 0.001;
}

class ClassAnalysisScreen extends StatelessWidget {
  const ClassAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'Class Analysis',
      role: 'staff',
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getClassAnalysis(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          }

          final data = snapshot.data ?? <String, dynamic>{};
          final subjects = List<Map<String, dynamic>>.from(
            data['subject_averages'] as List? ?? const [],
          );
          final toppers = List<Map<String, dynamic>>.from(
            data['top_performers'] as List? ?? const [],
          );
          final semesterStats = List<Map<String, dynamic>>.from(
            data['semester_stats'] as List? ?? const [],
          );
          final recentResults = List<Map<String, dynamic>>.from(
            data['recent_results'] as List? ?? const [],
          );
          final marksBands = Map<String, dynamic>.from(data['marks_bands'] as Map? ?? const {});

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SectionTitle(
                title: 'Class Overview',
                subtitle: 'These charts are generated directly from all uploaded result rows in the backend.',
              ),
              const SizedBox(height: 16),
              SummaryGrid(
                stats: {
                  'pass_percentage': '${data['pass_percentage'] ?? 0}%',
                  'fail_percentage': '${data['fail_percentage'] ?? 0}%',
                  'subjects_covered': subjects.length,
                  'recent_entries': recentResults.length,
                },
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 920;
                  final marksBandChart = _MarksBandChart(marksBands: marksBands);
                  final semesterChart = _SemesterStatsChart(semesterStats: semesterStats);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: marksBandChart),
                        const SizedBox(width: 16),
                        Expanded(child: semesterChart),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      marksBandChart,
                      const SizedBox(height: 16),
                      semesterChart,
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subject-wise Average Marks',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use this to identify which subjects are underperforming or consistently strong.',
                        style: TextStyle(color: kTextLight, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 340,
                        child: subjects.isEmpty
                            ? const Center(child: Text('No subject data available.'))
                            : BarChart(
                                BarChartData(
                                  maxY: 100,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 20,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.grey.withValues(alpha: 0.18),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 20,
                                        reservedSize: 34,
                                        getTitlesWidget: (value, meta) => Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(fontSize: 11, color: kTextLight),
                                        ),
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        reservedSize: 52,
                                        getTitlesWidget: (value, meta) {
                                          if (!_isAxisIndex(value)) {
                                            return const SizedBox.shrink();
                                          }
                                          final index = value.toInt();
                                          if (index < 0 || index >= subjects.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              subjects[index]['subject_name']?.toString() ?? '',
                                              style: const TextStyle(fontSize: 10, color: kTextLight),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: [
                                    for (var i = 0; i < subjects.length; i++)
                                      BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: (subjects[i]['average_marks'] as num?)?.toDouble() ?? 0,
                                            width: 22,
                                            borderRadius: BorderRadius.circular(8),
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF8F0D12), Color(0xFFDA7A6C)],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final topperPanel = KeyValuePanel(
                    title: 'Top Performers',
                    icon: Icons.star_outline,
                    items: toppers
                        .map(
                          (topper) => MapEntry(
                            topper['name']?.toString() ?? '-',
                            '${topper['register_number'] ?? ''} | CGPA ${topper['cgpa'] ?? 0}',
                          ),
                        )
                        .toList(),
                  );
                  final recentPanel = TimelineList(
                    title: 'Recent Result Activity',
                    items: recentResults
                        .map(
                          (item) => {
                            'title': item['student_name'],
                            'detail':
                                '${item['register_number']} | ${item['subject_name']} | S${item['semester']} | ${item['marks']}',
                          },
                        )
                        .toList(),
                    emptyLabel: 'Recent result uploads will appear here.',
                  );
                  if (constraints.maxWidth > 920) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: topperPanel),
                        const SizedBox(width: 16),
                        Expanded(child: recentPanel),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      topperPanel,
                      const SizedBox(height: 16),
                      recentPanel,
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MarksBandChart extends StatelessWidget {
  const _MarksBandChart({required this.marksBands});

  final Map<String, dynamic> marksBands;

  @override
  Widget build(BuildContext context) {
    final entries = marksBands.entries.toList();
    final colors = <Color>[
      const Color(0xFF3D9970),
      const Color(0xFFE8B24F),
      const Color(0xFFC95B4B),
      const Color(0xFF8F0D12),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Marks Band Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'This shows how many saved results fall into each marks range.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: entries.isEmpty
                  ? const Center(child: Text('No marks band data available.'))
                  : PieChart(
                      PieChartData(
                        centerSpaceRadius: 54,
                        sectionsSpace: 4,
                        sections: [
                          for (var i = 0; i < entries.length; i++)
                            PieChartSectionData(
                              color: colors[i % colors.length],
                              value: (entries[i].value as num?)?.toDouble() ?? 0,
                              title: '${entries[i].value}',
                              radius: 78,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${entries[i].key} (${entries[i].value})'),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterStatsChart extends StatelessWidget {
  const _SemesterStatsChart({required this.semesterStats});

  final List<Map<String, dynamic>> semesterStats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Semester Average Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Each point here reflects the average marks for a semester across uploaded records.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: semesterStats.isEmpty
                  ? const Center(child: Text('No semester stats available.'))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.18),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                              reservedSize: 34,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: kTextLight, fontSize: 11),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (!_isAxisIndex(value)) {
                                  return const SizedBox.shrink();
                                }
                                final index = value.toInt();
                                if (index < 0 || index >= semesterStats.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'S${semesterStats[index]['semester']}',
                                    style: const TextStyle(color: kTextLight, fontSize: 11),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < semesterStats.length; i++)
                                FlSpot(i.toDouble(), (semesterStats[i]['average_marks'] as num?)?.toDouble() ?? 0),
                            ],
                            color: kPrimaryColor,
                            barWidth: 4,
                            isCurved: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: kPrimaryColor.withValues(alpha: 0.1),
                            ),
                          ),
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
