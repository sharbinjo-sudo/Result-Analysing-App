import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

bool _isAxisIndex(double value) {
  return (value - value.roundToDouble()).abs() < 0.001;
}

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'Performance Analysis',
      role: 'student',
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getMyAnalysis(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          }

          final data = snapshot.data ?? <String, dynamic>{};
          final overview = Map<String, dynamic>.from(data['overview'] as Map? ?? {});
          final trend = List<Map<String, dynamic>>.from(data['semester_trend'] as List? ?? const []);
          final subjects =
              List<Map<String, dynamic>>.from(data['last_semester_subjects'] as List? ?? const []);
          final strengths = List<Map<String, dynamic>>.from(data['strengths'] as List? ?? const []);
          final gradeDistribution = Map<String, dynamic>.from(
            data['grade_distribution'] as Map? ?? const {},
          );

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SectionTitle(
                title: 'Performance Overview',
                subtitle: 'All analytics on this page are calculated from the result records stored in the backend.',
              ),
              const SizedBox(height: 16),
              SummaryGrid(
                stats: {
                  'overall_average_marks': overview['overall_average_marks'] ?? 0,
                  'overall_cgpa': overview['overall_cgpa'] ?? 0,
                  'total_subjects': overview['total_subjects'] ?? 0,
                  'semesters': trend.length,
                },
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 920;
                  final trendChart = _SemesterTrendChart(trend: trend);
                  final gradesCard = _GradeDistributionCard(gradeDistribution: gradeDistribution);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: trendChart),
                        const SizedBox(width: 16),
                        Expanded(child: gradesCard),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      trendChart,
                      const SizedBox(height: 16),
                      gradesCard,
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final subjectChart = _LatestSubjectChart(subjects: subjects);
                  final strengthsPanel = KeyValuePanel(
                    title: 'Strongest Subjects',
                    icon: Icons.emoji_events_outlined,
                    items: strengths
                        .take(6)
                        .map(
                          (item) => MapEntry(
                            item['subject_name']?.toString() ?? '-',
                            '${item['average_marks'] ?? 0}',
                          ),
                        )
                        .toList(),
                  );
                  if (constraints.maxWidth > 920) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: subjectChart),
                        const SizedBox(width: 16),
                        Expanded(child: strengthsPanel),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      subjectChart,
                      const SizedBox(height: 16),
                      strengthsPanel,
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

class _SemesterTrendChart extends StatelessWidget {
  const _SemesterTrendChart({required this.trend});

  final List<Map<String, dynamic>> trend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Semester Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Average marks use the left axis, while the right axis shows CGPA values.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 320,
              child: trend.isEmpty
                  ? const Center(child: Text('Analysis will appear after results are uploaded.'))
                  : Column(
                      children: [
                        Row(
                          children: const [
                            _ChartLegend(color: kPrimaryColor, label: 'Average Marks'),
                            SizedBox(width: 16),
                            _ChartLegend(
                              color: kAccentColor,
                              label: 'CGPA',
                              dashed: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LineChart(
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
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 20,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) => Text(
                                      (value / 10).toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 11, color: kTextLight),
                                    ),
                                  ),
                                ),
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
                                    getTitlesWidget: (value, meta) {
                                      if (!_isAxisIndex(value)) {
                                        return const SizedBox.shrink();
                                      }
                                      final index = value.toInt();
                                      if (index < 0 || index >= trend.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          trend[index]['label']?.toString() ?? '',
                                          style: const TextStyle(fontSize: 11, color: kTextLight),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (var i = 0; i < trend.length; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        (trend[i]['average_marks'] as num?)?.toDouble() ?? 0,
                                      ),
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
                                LineChartBarData(
                                  spots: [
                                    for (var i = 0; i < trend.length; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        ((trend[i]['cgpa'] as num?)?.toDouble() ?? 0) * 10,
                                      ),
                                  ],
                                  color: kAccentColor,
                                  barWidth: 3,
                                  isCurved: true,
                                  dotData: const FlDotData(show: true),
                                  dashArray: const [8, 4],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeDistributionCard extends StatelessWidget {
  const _GradeDistributionCard({required this.gradeDistribution});

  final Map<String, dynamic> gradeDistribution;

  @override
  Widget build(BuildContext context) {
    final items = gradeDistribution.entries.toList();
    final palette = <Color>[
      const Color(0xFF8F0D12),
      const Color(0xFFC95B4B),
      const Color(0xFFE8B24F),
      const Color(0xFF4D7C8A),
      const Color(0xFF3D9970),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grade Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'This breaks down how many subjects fall under each grade band.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: items.isEmpty
                  ? const Center(child: Text('No grade distribution available.'))
                  : PieChart(
                      PieChartData(
                        centerSpaceRadius: 52,
                        sectionsSpace: 4,
                        sections: [
                          for (var i = 0; i < items.length; i++)
                            PieChartSectionData(
                              color: palette[i % palette.length],
                              value: (items[i].value as num?)?.toDouble() ?? 0,
                              title: '${items[i].value}',
                              radius: 76,
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
                for (var i = 0; i < items.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: palette[i % palette.length],
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${items[i].key} (${items[i].value})'),
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

class _LatestSubjectChart extends StatelessWidget {
  const _LatestSubjectChart({required this.subjects});

  final List<Map<String, dynamic>> subjects;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Semester Subject Marks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Each bar here reflects the most recent semester stored in the result database.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: subjects.isEmpty
                  ? const Center(child: Text('No latest semester data available.'))
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
                              reservedSize: 32,
                              interval: 20,
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
                              reservedSize: 54,
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
                                    subjects[index]['subject_code']?.toString() ??
                                        subjects[index]['subject_name']?.toString() ??
                                        '',
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
                                  toY: (subjects[i]['marks'] as num?)?.toDouble() ?? 0,
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
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(999),
            border: dashed ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: kTextLight)),
      ],
    );
  }
}
