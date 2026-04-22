import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

bool _isAxisIndex(double value) {
  return (value - value.roundToDouble()).abs() < 0.001;
}

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'Staff Dashboard',
      role: 'staff',
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getDashboardSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          }

          final data = snapshot.data ?? <String, dynamic>{};
          final stats = Map<String, dynamic>.from(data['stats'] as Map? ?? {});
          final recentNotices =
              List<Map<String, dynamic>>.from(data['recent_notices'] as List? ?? const []);
          final subjectHighlights =
              List<Map<String, dynamic>>.from(data['subject_highlights'] as List? ?? const []);
          final recentUploads =
              List<Map<String, dynamic>>.from(data['recent_uploads'] as List? ?? const []);
          final welcomeName = (data['welcome_name'] as String?) ?? 'Staff';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DashboardHero(
                title: 'Welcome, $welcomeName',
                subtitle:
                    'Monitor the latest uploads, class performance, and student outcomes from the backend without losing the existing staff workflow.',
                badges: [
                  'Results Uploaded ${stats['results_uploaded'] ?? 0}',
                  'Students ${stats['students_managed'] ?? 0}',
                  'Pass ${stats['pass_percentage'] ?? 0}%',
                ],
              ),
              const SizedBox(height: 24),
              SummaryGrid(stats: stats),
              const SizedBox(height: 28),
              const SectionTitle(
                title: 'Quick Access',
                subtitle: 'The same staff tools are kept in place, now backed by live academic data.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ActionCard(
                    title: 'Upload Results',
                    description: 'Push manual semester result entries directly into the backend.',
                    icon: Icons.upload_file_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/staffUploadResults'),
                  ),
                  ActionCard(
                    title: 'Class Analysis',
                    description: 'Review pass percentage, subject averages, and toppers.',
                    icon: Icons.bar_chart_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/staffClassAnalysis'),
                  ),
                  ActionCard(
                    title: 'Student Insights',
                    description: 'Search students and inspect semester trends with printable summaries.',
                    icon: Icons.people_outline,
                    onTap: () => Navigator.pushReplacementNamed(context, '/staffStudentInsights'),
                  ),
                  ActionCard(
                    title: 'College Notices',
                    description: 'Read notices shared by the administration.',
                    icon: Icons.notifications_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/collegeNoticesStaff'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chart = _SubjectHighlightChart(subjectHighlights: subjectHighlights);
                  final uploads = TimelineList(
                    title: 'Recent Uploads',
                    items: recentUploads
                        .map(
                          (item) => {
                            'title': item['student_name'],
                            'detail':
                                '${item['register_number']} | S${item['semester']} | ${item['subject_name']} | ${item['marks']}',
                          },
                        )
                        .toList(),
                    emptyLabel: 'Your recent result uploads will appear here.',
                  );
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: chart),
                        const SizedBox(width: 16),
                        Expanded(child: uploads),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: 16),
                      uploads,
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              TimelineList(
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
                emptyLabel: 'No recent notices.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SubjectHighlightChart extends StatelessWidget {
  const _SubjectHighlightChart({required this.subjectHighlights});

  final List<Map<String, dynamic>> subjectHighlights;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Subject Averages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'These values come from all saved result entries and help you spot strong subjects quickly.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: subjectHighlights.isEmpty
                  ? const Center(child: Text('No subject data available yet.'))
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
                              reservedSize: 46,
                              getTitlesWidget: (value, meta) {
                                if (!_isAxisIndex(value)) {
                                  return const SizedBox.shrink();
                                }
                                final index = value.toInt();
                                if (index < 0 || index >= subjectHighlights.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    subjectHighlights[index]['subject_name']?.toString() ?? '',
                                    style: const TextStyle(color: kTextLight, fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < subjectHighlights.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: (subjectHighlights[i]['average_marks'] as num?)?.toDouble() ?? 0,
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
