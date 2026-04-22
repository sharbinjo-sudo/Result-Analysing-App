import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<Map<String, dynamic>> _future;
  String? _selectedSemester;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getMyResults();
  }

  Future<void> _printSemester(Map<String, dynamic> semesterData) async {
    final pdf = pw.Document();
    final semesterName = semesterData['semester'] as String? ?? 'Semester';
    final results = List<Map<String, dynamic>>.from(
      semesterData['results'] as List? ?? const [],
    );

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Result Report - $semesterName',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red900,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: const ['Subject', 'Code', 'Marks', 'Grade'],
                data: results
                    .map(
                      (result) => [
                        result['subject_name']?.toString() ?? '',
                        result['subject_code']?.toString() ?? '',
                        result['marks']?.toString() ?? '',
                        result['grade']?.toString() ?? '',
                      ],
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return CollegeScaffold(
      title: 'My Results',
      role: 'student',
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          }

          final semesters = List<Map<String, dynamic>>.from(
            snapshot.data?['semesters'] as List? ?? const [],
          );
          if (semesters.isEmpty) {
            return const Center(child: Text('No results have been uploaded yet.'));
          }

          _selectedSemester ??= semesters.first['semester'] as String;
          final selectedData = semesters.firstWhere(
            (item) => item['semester'] == _selectedSemester,
            orElse: () => semesters.first,
          );
          final selectedResults = List<Map<String, dynamic>>.from(
            selectedData['results'] as List? ?? const [],
          );
          final subjectCount =
              _toInt(selectedData['subjects']) ?? selectedResults.length;
          final averageMarks = _toDouble(selectedData['average_marks']) ??
              _averageForResults(selectedResults);
          final highestMark = selectedResults
              .map((row) => _toDouble(row['marks']) ?? 0)
              .fold<double>(0, (best, mark) => mark > best ? mark : best);
          final passCount = selectedResults
              .where((row) => (_toDouble(row['marks']) ?? 0) >= 50)
              .length;
          final passRate = selectedResults.isEmpty
              ? 0.0
              : (passCount / selectedResults.length) * 100;
          final topGrade = selectedResults
              .map((row) => row['grade']?.toString() ?? '')
              .where((grade) => grade.isNotEmpty)
              .fold<String>('', (best, current) {
                if (best.isEmpty) return current;
                return _gradeRank(current) < _gradeRank(best) ? current : best;
              });
          final gradeCounts = <String, int>{};
          for (final row in selectedResults) {
            final grade = row['grade']?.toString() ?? '-';
            gradeCounts.update(grade, (value) => value + 1, ifAbsent: () => 1);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DashboardHero(
                title: 'Semester Performance',
                subtitle:
                    'Review your marks, subject-wise grades, and semester summary in one clean report view.',
                badges: [
                  selectedData['semester']?.toString() ?? 'Semester',
                  '$subjectCount Subjects',
                  '${averageMarks.toStringAsFixed(1)} Average',
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 760;
                  return Flex(
                    direction: stacked ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: stacked ? 0 : 3,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionTitle(
                                  title: 'Select Semester',
                                  subtitle:
                                      'Switch between semesters or print the current result sheet.',
                                ),
                                const SizedBox(height: 18),
                                if (stacked)
                                  Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedSemester,
                                        decoration: const InputDecoration(
                                          labelText: 'Semester',
                                        ),
                                        items: semesters
                                            .map(
                                              (semester) => DropdownMenuItem<String>(
                                                value: semester['semester'] as String,
                                                child: Text(semester['semester'] as String),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) =>
                                            setState(() => _selectedSemester = value),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          onPressed: () => _printSemester(selectedData),
                                          icon: const Icon(Icons.picture_as_pdf_outlined),
                                          label: const Text('Export PDF'),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _selectedSemester,
                                          decoration: const InputDecoration(
                                            labelText: 'Semester',
                                          ),
                                          items: semesters
                                              .map(
                                                (semester) => DropdownMenuItem<String>(
                                                  value: semester['semester'] as String,
                                                  child: Text(semester['semester'] as String),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (value) =>
                                              setState(() => _selectedSemester = value),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      FilledButton.icon(
                                        onPressed: () => _printSemester(selectedData),
                                        icon: const Icon(Icons.picture_as_pdf_outlined),
                                        label: const Text('Export PDF'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!stacked) const SizedBox(width: 16) else const SizedBox(height: 16),
                      Expanded(
                        flex: stacked ? 0 : 2,
                        child: _SemesterHighlightCard(
                          semesterLabel: selectedData['semester']?.toString() ?? 'Semester',
                          averageMarks: averageMarks,
                          passRate: passRate,
                          topGrade: topGrade.isEmpty ? '-' : topGrade,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ResultStatCard(
                    label: 'Subjects',
                    value: '$subjectCount',
                    icon: Icons.menu_book_outlined,
                    accent: const Color(0xFFE9F2FF),
                  ),
                  _ResultStatCard(
                    label: 'Average Marks',
                    value: averageMarks.toStringAsFixed(1),
                    icon: Icons.analytics_outlined,
                    accent: const Color(0xFFFFF2E2),
                  ),
                  _ResultStatCard(
                    label: 'Highest Score',
                    value: highestMark.toStringAsFixed(0),
                    icon: Icons.workspace_premium_outlined,
                    accent: const Color(0xFFEFFBF3),
                  ),
                  _ResultStatCard(
                    label: 'Pass Rate',
                    value: '${passRate.toStringAsFixed(0)}%',
                    icon: Icons.trending_up_outlined,
                    accent: const Color(0xFFFFEEF1),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Grade Snapshot',
                        subtitle:
                            'A quick breakdown of the grades you earned in the selected semester.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: gradeCounts.entries
                            .map(
                              (entry) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _gradeColor(entry.key).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: _gradeColor(entry.key).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  '${entry.key} | ${entry.value}',
                                  style: TextStyle(
                                    color: _gradeColor(entry.key),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Detailed Results',
                        subtitle:
                            'Every subject shown below is loaded from the backend for the selected semester.',
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 760) {
                            return Column(
                              children: [
                                for (final row in selectedResults) ...[
                                  _ResultSubjectCard(row: row),
                                  const SizedBox(height: 14),
                                ],
                              ],
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: DataTable(
                                headingRowColor: WidgetStatePropertyAll(
                                  kPrimaryColor.withValues(alpha: 0.08),
                                ),
                                dataRowMinHeight: 64,
                                dataRowMaxHeight: 72,
                                columns: const [
                                  DataColumn(label: Text('Subject')),
                                  DataColumn(label: Text('Code')),
                                  DataColumn(label: Text('Marks')),
                                  DataColumn(label: Text('Grade')),
                                ],
                                rows: selectedResults
                                    .map(
                                      (row) => DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: 240,
                                              child: Text(
                                                row['subject_name']?.toString() ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(row['subject_code']?.toString() ?? ''),
                                          ),
                                          DataCell(
                                            Text(row['marks']?.toString() ?? ''),
                                          ),
                                          DataCell(
                                            _GradeBadge(
                                              grade: row['grade']?.toString() ?? '-',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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

double _averageForResults(List<Map<String, dynamic>> results) {
  if (results.isEmpty) return 0;
  final total = results.fold<double>(
    0,
    (sum, row) => sum + (_toDouble(row['marks']) ?? 0),
  );
  return total / results.length;
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

int _gradeRank(String grade) {
  const order = ['O', 'A+', 'A', 'B+', 'B', 'C', 'RA', 'U', '-'];
  final index = order.indexOf(grade.toUpperCase());
  return index == -1 ? order.length : index;
}

Color _gradeColor(String grade) {
  switch (grade.toUpperCase()) {
    case 'O':
    case 'A+':
      return const Color(0xFF138A4A);
    case 'A':
    case 'B+':
      return const Color(0xFF1D6FD8);
    case 'B':
    case 'C':
      return const Color(0xFFE38B18);
    default:
      return const Color(0xFFB11116);
  }
}

class _ResultStatCard extends StatelessWidget {
  const _ResultStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: kPrimaryColor),
            ),
            const SizedBox(height: 18),
            Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterHighlightCard extends StatelessWidget {
  const _SemesterHighlightCard({
    required this.semesterLabel,
    required this.averageMarks,
    required this.passRate,
    required this.topGrade,
  });

  final String semesterLabel;
  final double averageMarks;
  final double passRate;
  final String topGrade;

  @override
  Widget build(BuildContext context) {
    final normalizedAverage = (averageMarks / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7EC), Color(0xFFFFEFE1), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            semesterLabel,
            style: const TextStyle(
              color: kPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your current semester snapshot',
            style: TextStyle(color: kTextLight, height: 1.5),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalizedAverage,
              minHeight: 12,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniHighlight(
                  label: 'Average',
                  value: averageMarks.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: _MiniHighlight(
                  label: 'Pass Rate',
                  value: '${passRate.toStringAsFixed(0)}%',
                ),
              ),
              Expanded(
                child: _MiniHighlight(
                  label: 'Top Grade',
                  value: topGrade,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniHighlight extends StatelessWidget {
  const _MiniHighlight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kTextLight, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: kTextDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ResultSubjectCard extends StatelessWidget {
  const _ResultSubjectCard({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final grade = row['grade']?.toString() ?? '-';
    final marks = row['marks']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row['subject_name']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      row['subject_code']?.toString() ?? '',
                      style: const TextStyle(color: kTextLight),
                    ),
                  ],
                ),
              ),
              _GradeBadge(grade: grade),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: kPrimaryColor),
                const SizedBox(width: 10),
                const Text(
                  'Marks Obtained',
                  style: TextStyle(color: kTextLight, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  marks,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade});

  final String grade;

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(grade);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
