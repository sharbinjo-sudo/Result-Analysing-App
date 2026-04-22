import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

bool _isAxisIndex(double value) {
  return (value - value.roundToDouble()).abs() < 0.001;
}

class StudentInsightsScreen extends StatefulWidget {
  const StudentInsightsScreen({super.key});

  @override
  State<StudentInsightsScreen> createState() => _StudentInsightsScreenState();
}

class _StudentInsightsScreenState extends State<StudentInsightsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getStudentInsights();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _future = ApiService.getStudentInsights(_searchController.text.trim());
    });
  }

  Future<void> _printStudent(Map<String, dynamic> student) async {
    final pdf = pw.Document();
    final subjects = Map<String, dynamic>.from(student['subjects'] as Map? ?? {});
    final semesters = List<Map<String, dynamic>>.from(student['semesters'] as List? ?? const []);

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  student['name']?.toString() ?? 'Student',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Register No: ${student['regNo'] ?? '-'}'),
                pw.Text('Department: ${student['dept'] ?? '-'}'),
                pw.Text('Year / Section: ${student['year_of_study'] ?? '-'} / ${student['section'] ?? '-'}'),
                pw.Text('CGPA: ${student['cgpa'] ?? '-'}'),
                pw.Text('Average Marks: ${student['average_marks'] ?? '-'}'),
                pw.SizedBox(height: 16),
                pw.Text('Semester Overview'),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  headers: const ['Semester', 'GPA', 'Avg Marks'],
                  data: semesters
                      .map(
                        (item) => [
                          item['label']?.toString() ?? '',
                          item['gpa']?.toString() ?? '',
                          item['average_marks']?.toString() ?? '',
                        ],
                      )
                      .toList(),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Latest Subject Marks'),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  headers: const ['Subject', 'Marks'],
                  data: subjects.entries.map((entry) => [entry.key, '${entry.value}']).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  void _openStudentDialog(Map<String, dynamic> student) {
    final semesters = List<Map<String, dynamic>>.from(student['semesters'] as List? ?? const []);
    final subjects = Map<String, dynamic>.from(student['subjects'] as Map? ?? {});

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['name']?.toString() ?? 'Student',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${student['regNo'] ?? '-'} | ${student['dept'] ?? '-'} | Year ${student['year_of_study'] ?? '-'} | Section ${student['section'] ?? '-'}',
                              style: const TextStyle(color: kTextLight),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _printStudent(student),
                        icon: const Icon(Icons.picture_as_pdf),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SummaryGrid(
                    stats: {
                      'cgpa': student['cgpa'] ?? 0,
                      'average_marks': student['average_marks'] ?? 0,
                      'total_subjects': student['total_subjects'] ?? 0,
                      'latest_semester': student['latest_semester'] ?? '-',
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 240,
                    child: semesters.isEmpty
                        ? const Center(child: Text('No semester history available.'))
                        : LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 10,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 2,
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
                                    interval: 2,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toStringAsFixed(0),
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
                                      if (index < 0 || index >= semesters.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          semesters[index]['label']?.toString() ?? '',
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
                                    for (var i = 0; i < semesters.length; i++)
                                      FlSpot(i.toDouble(), (semesters[i]['gpa'] as num?)?.toDouble() ?? 0),
                                  ],
                                  color: kPrimaryColor,
                                  isCurved: true,
                                  barWidth: 4,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 18),
                  KeyValuePanel(
                    title: 'Latest Subject Marks',
                    icon: Icons.menu_book_outlined,
                    items: subjects.entries
                        .map((entry) => MapEntry(entry.key, '${entry.value}'))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'Student Insights',
      role: 'staff',
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          }

          final students = List<Map<String, dynamic>>.from(
            snapshot.data?['students'] as List? ?? const [],
          );

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SectionTitle(
                title: 'Student Search',
                subtitle: 'Search the backend records by name or register number and inspect each student in detail.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by name or register number',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _search, child: const Text('Search')),
                ],
              ),
              const SizedBox(height: 20),
              if (students.isEmpty)
                const Center(child: Text('No students matched your search.'))
              else
                ...students.map(
                  (student) => Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      title: Text(
                        student['name']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${student['regNo'] ?? ''} | ${student['dept'] ?? ''} | Year ${student['year_of_study'] ?? '-'} | Section ${student['section'] ?? '-'}\nAverage ${student['average_marks'] ?? 0} | CGPA ${student['cgpa'] ?? 0}',
                          style: const TextStyle(height: 1.5, color: kTextLight),
                        ),
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openStudentDialog(student),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
