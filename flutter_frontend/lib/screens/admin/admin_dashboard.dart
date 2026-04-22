import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'Admin Dashboard',
      role: 'admin',
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
          final pendingUsers =
              List<Map<String, dynamic>>.from(data['pending_users'] as List? ?? const []);
          final departmentBreakdown =
              List<Map<String, dynamic>>.from(data['department_breakdown'] as List? ?? const []);
          final recentNotices =
              List<Map<String, dynamic>>.from(data['recent_notices'] as List? ?? const []);
          final welcomeName = (data['welcome_name'] as String?) ?? 'Admin';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DashboardHero(
                title: 'Welcome, $welcomeName',
                subtitle:
                    'Oversee user approvals, department distribution, and published notices from a single administrative view powered by the backend database.',
                badges: [
                  'Users ${stats['total_users'] ?? 0}',
                  'Pending ${stats['pending_approvals'] ?? 0}',
                  'Notices ${stats['notices'] ?? 0}',
                ],
              ),
              const SizedBox(height: 24),
              SummaryGrid(stats: stats),
              const SizedBox(height: 28),
              const SectionTitle(
                title: 'Quick Access',
                subtitle: 'The old admin structure stays intact while the visuals and live metrics are improved.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ActionCard(
                    title: 'User Management',
                    description: 'Create, approve, update, and remove student or staff accounts.',
                    icon: Icons.people_alt_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/adminUserManagement'),
                  ),
                  ActionCard(
                    title: 'Manage Notices',
                    description: 'Publish official circulars for the entire college.',
                    icon: Icons.campaign_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, '/collegeNoticesAdmin'),
                  ),
                  ActionCard(
                    title: 'Profile',
                    description: 'Review your administrator account details.',
                    icon: Icons.person_outline,
                    onTap: () => Navigator.pushReplacementNamed(context, '/adminProfile'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chart = _DepartmentChart(items: departmentBreakdown);
                  final approvals = TimelineList(
                    title: 'Pending Approvals',
                    items: pendingUsers
                        .map(
                          (item) => {
                            'title': item['name'],
                            'detail':
                                '${item['role'] ?? ''} | ${item['department'] ?? '-'} | ${item['email'] ?? ''}',
                          },
                        )
                        .toList(),
                    emptyLabel: 'No accounts are waiting for approval.',
                  );
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: chart),
                        const SizedBox(width: 16),
                        Expanded(child: approvals),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: 16),
                      approvals,
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
                emptyLabel: 'No notices available.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DepartmentChart extends StatelessWidget {
  const _DepartmentChart({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final palette = <Color>[
      const Color(0xFF8F0D12),
      const Color(0xFFC95B4B),
      const Color(0xFFE8B24F),
      const Color(0xFF4D7C8A),
      const Color(0xFF3D9970),
      const Color(0xFF6C5B7B),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Department Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This chart shows how active users are spread across departments in the database.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 300,
              child: items.isEmpty
                  ? const Center(child: Text('No department data available.'))
                  : PieChart(
                      PieChartData(
                        centerSpaceRadius: 54,
                        sectionsSpace: 4,
                        sections: [
                          for (var i = 0; i < items.length; i++)
                            PieChartSectionData(
                              color: palette[i % palette.length],
                              value: (items[i]['total'] as num?)?.toDouble() ?? 0,
                              title: '${items[i]['total']}',
                              radius: 80,
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
                      Text('${items[i]['department']} (${items[i]['total']})'),
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
