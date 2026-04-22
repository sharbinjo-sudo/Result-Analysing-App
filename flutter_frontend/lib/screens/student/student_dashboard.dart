import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

bool _isAxisIndex(double value) {
  return (value - value.roundToDouble()).abs() < 0.001;
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'Student Dashboard',
      role: 'student',
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getDashboardSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _DashboardError(message: snapshot.error.toString());
          }

          final data = snapshot.data ?? <String, dynamic>{};
          final stats = Map<String, dynamic>.from(data['stats'] as Map? ?? {});
          final overview = Map<String, dynamic>.from(data['student_overview'] as Map? ?? {});
          final trend = List<Map<String, dynamic>>.from(data['trend'] as List? ?? const []);
          final recentNotices =
              List<Map<String, dynamic>>.from(data['recent_notices'] as List? ?? const []);
          final latestResults =
              List<Map<String, dynamic>>.from(data['latest_results'] as List? ?? const []);
          final welcomeName = (data['welcome_name'] as String?) ?? 'Student';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DashboardHero(
                title: 'Welcome, $welcomeName',
                subtitle:
                    'Track semester performance, stay updated with notices, and review your academic progress from live college data.',
                badges: [
                  overview['department']?.toString() ?? '-',
                  'Year ${overview['year_of_study'] ?? '-'}',
                  'Section ${overview['section'] ?? '-'}',
                ],
              ),
              const SizedBox(height: 24),
              SummaryGrid(stats: stats),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  final trendChart = _TrendCard(trend: trend);
                  final profilePanel = KeyValuePanel(
                    title: 'Academic Snapshot',
                    icon: Icons.school_outlined,
                    items: [
                      MapEntry('Register Number', overview['register_number']?.toString() ?? '-'),
                      MapEntry('Department', overview['department']?.toString() ?? '-'),
                      MapEntry('Year of Study', '${overview['year_of_study'] ?? '-'}'),
                      MapEntry('Section', overview['section']?.toString() ?? '-'),
                    ],
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: trendChart),
                        const SizedBox(width: 16),
                        Expanded(child: profilePanel),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      trendChart,
                      const SizedBox(height: 16),
                      profilePanel,
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              const SectionTitle(
                title: 'Quick Access',
                subtitle: 'The familiar student flow is preserved here with a cleaner production look.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ActionCard(
                    title: 'My Results',
                    description: 'See semester-wise marks and printable result tables.',
                    icon: Icons.grade_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/studentResults'),
                  ),
                  ActionCard(
                    title: 'Performance Analysis',
                    description: 'Track semester trends and last semester subject performance.',
                    icon: Icons.analytics_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/studentAnalysis'),
                  ),
                  ActionCard(
                    title: 'Profile',
                    description: 'Check your academic and account details.',
                    icon: Icons.person_outline,
                    onTap: () => Navigator.pushReplacementNamed(context, '/studentProfile'),
                  ),
                  ActionCard(
                    title: 'College Notices',
                    description: 'Read official updates published by the admin team.',
                    icon: Icons.notifications_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/collegeNoticesStudent'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  final notices = TimelineList(
                    title: 'Recent Notices',
                    items: recentNotices
                        .map(
                          (item) => {
                            'title': item['title'],
                            'detail':
                                '${item['created_by_name'] ?? 'Admin'} | ${(item['created_at'] ?? '').toString().replaceFirst('T', ' ')}',
                            'description': item['description'],
                          },
                        )
                        .toList(),
                    emptyLabel: 'No notices published yet.',
                  );
                  final results = TimelineList(
                    title: 'Latest Semester Results',
                    items: latestResults
                        .map(
                          (item) => {
                            'title': item['subject_name'],
                            'detail':
                                '${item['subject_code']} | Marks ${item['marks']} | Grade ${item['grade']}',
                          },
                        )
                        .toList(),
                    emptyLabel: 'Results will appear after your records are uploaded.',
                  );
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: notices),
                        const SizedBox(width: 16),
                        Expanded(child: results),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      notices,
                      const SizedBox(height: 16),
                      results,
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

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend});

  final List<Map<String, dynamic>> trend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semester Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Average marks and GPA are loaded from your saved result history.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 280,
              child: trend.isEmpty
                  ? const Center(child: Text('No performance data yet.'))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 20,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.2),
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
                              reservedSize: 34,
                              interval: 20,
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
                                if (index < 0 || index >= trend.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    trend[index]['label']?.toString() ?? '',
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
                              for (var i = 0; i < trend.length; i++)
                                FlSpot(
                                  i.toDouble(),
                                  (trend[i]['average_marks'] as num?)?.toDouble() ?? 0,
                                ),
                            ],
                            color: kPrimaryColor,
                            barWidth: 4,
                            dotData: const FlDotData(show: true),
                            isCurved: true,
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

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 44, color: Color(0xFFB11116)),
            const SizedBox(height: 12),
            const Text(
              'Unable to load dashboard right now.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message.replaceFirst('Exception: ', '')),
          ],
        ),
      ),
    );
  }
}
