// lib/screens/staff/student_insights_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../widgets/sidebar.dart';

class StudentInsightsScreen extends StatefulWidget {
  const StudentInsightsScreen({super.key});

  @override
  State<StudentInsightsScreen> createState() => _StudentInsightsScreenState();
}

class _StudentInsightsScreenState extends State<StudentInsightsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _isOpen = false;
  bool _navigating = false;

  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;

  // --- students store (multiple students) ---
  final List<Map<String, dynamic>> students = [
    {
      "name": "A. Karthik",
      "regNo": "VV2025CSE003",
      "dept": "Computer Science and Engineering",
      "cgpa": 8.92,
      "semesters": [8.3, 8.7, 9.0, 9.3],
      "subjects": {"Maths": 85, "DS": 90, "OOPS": 92, "DBMS": 88, "CN": 80},
    },
    {
      "name": "S. Meena",
      "regNo": "VV2025CSE005",
      "dept": "Computer Science and Engineering",
      "cgpa": 9.12,
      "semesters": [8.6, 9.0, 9.1, 9.2],
      "subjects": {"Maths": 88, "DS": 92, "OOPS": 90, "DBMS": 91, "CN": 85},
    },
    {
      "name": "R. Aravind",
      "regNo": "VV2025CSE008",
      "dept": "Computer Science and Engineering",
      "cgpa": 8.75,
      "semesters": [7.8, 8.2, 8.9, 9.1],
      "subjects": {"Maths": 80, "DS": 85, "OOPS": 88, "DBMS": 86, "CN": 78},
    },
    {
      "name": "N. Priya",
      "regNo": "VV2025CSE012",
      "dept": "Computer Science and Engineering",
      "cgpa": 8.45,
      "semesters": [7.9, 8.1, 8.4, 8.8],
      "subjects": {"Maths": 78, "DS": 82, "OOPS": 84, "DBMS": 81, "CN": 77},
    },
  ];

  // UI state
  List<Map<String, dynamic>> filtered = [];
  final Map<String, bool> selected = {}; // regNo -> bool

  @override
  void initState() {
    super.initState();
    filtered = List.from(students);
    for (var s in students) selected[s['regNo']] = false;

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _sidebarTranslate =
        Tween<double>(begin: -sidebarWidth, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    _contentTranslate =
        Tween<double>(begin: 0, end: sidebarWidth).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    if (_navigating) return;
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  Future<void> _handleSidebarNavigation(String route) async {
    if (_navigating) return;
    _navigating = true;

    if (ModalRoute.of(context)?.settings.name == route) {
      await _controller.reverse();
      setState(() => _isOpen = false);
      _navigating = false;
      return;
    }

    if (mounted) Navigator.pushReplacementNamed(context, route);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) {
        await _controller.reverse();
        setState(() => _isOpen = false);
      }
      _navigating = false;
    });
  }

  void _runFilter(String q) {
    final t = q.trim().toLowerCase();
    setState(() {
      if (t.isEmpty) {
        filtered = List.from(students);
      } else {
        filtered = students.where((s) {
          final name = (s['name'] as String).toLowerCase();
          final reg = (s['regNo'] as String).toLowerCase();
          return name.contains(t) || reg.contains(t);
        }).toList();
      }
      // ensure selection keys exist for filtered entries (keeps prior selected state)
      for (var s in filtered) {
        selected.putIfAbsent(s['regNo'], () => false);
      }
    });
  }

  void _toggleSelect(String regNo, bool? value) {
    setState(() {
      selected[regNo] = value ?? false;
    });
  }

  Future<void> _printSelected() async {
    final toPrint = selected.entries.where((e) => e.value).map((e) => e.key).toList();
    if (toPrint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No students selected')));
      return;
    }

    final docs = pw.Document();
    for (var reg in toPrint) {
      final s = students.firstWhere((st) => st['regNo'] == reg, orElse: () => {});
      if (s.isEmpty) continue;
      docs.addPage(_studentPage(s));
    }

    await Printing.layoutPdf(onLayout: (format) async => docs.save());
  }

  Future<void> _printSingle(Map<String, dynamic> student) async {
    final doc = pw.Document();
    doc.addPage(_studentPage(student));
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  pw.Page _studentPage(Map<String, dynamic> student) {
    final subjects = (student['subjects'] as Map<String, dynamic>);
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Student Insights Report',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
              pw.SizedBox(height: 12),
              pw.Text('Name: ${student['name']}'),
              pw.Text('Register No: ${student['regNo']}'),
              pw.Text('Department: ${student['dept']}'),
              pw.Text('CGPA: ${student['cgpa']}'),
              pw.SizedBox(height: 12),
              pw.Text('Semester GPA:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: List.generate(
                  (student['semesters'] as List).length,
                  (i) => pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 12),
                    child: pw.Text('S${i + 1}: ${student['semesters'][i]}'),
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Subject Marks:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Table.fromTextArray(
                headers: const ['Subject', 'Marks'],
                data: subjects.entries.map((e) => [e.key, e.value.toString()]).toList(),
                cellPadding: const pw.EdgeInsets.all(6),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStudentDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student['name'],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB11116)),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _printSingle(student);
                        },
                        icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFB11116)),
                        tooltip: 'Print this student',
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('Register No: ${student['regNo']}')),
                      Expanded(child: Text('CGPA: ${student['cgpa']}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: Text('Department: ${student['dept']}')),
                  const SizedBox(height: 12),
                  // Simple semester mini-chart (using small bars)
                  SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Semester-wise GPA', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: LineChart(
                                  LineChartData(
                                    minY: 0,
                                    maxY: 10,
                                    titlesData: FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        isCurved: true,
                                        color: const Color(0xFFB11116),
                                        barWidth: 3,
                                        spots: [
                                          for (int i = 0; i < (student['semesters'] as List).length; i++)
                                            FlSpot(i.toDouble(), (student['semesters'][i] as num).toDouble())
                                        ],
                                        belowBarData: BarAreaData(show: true, color: const Color(0xFFB11116).withOpacity(0.15)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Subject Marks', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: BarChart(
                                  BarChartData(
                                    gridData: FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(show: false),
                                    barGroups: [
                                      for (int i = 0; i < (student['subjects'] as Map).length; i++)
                                        BarChartGroupData(x: i, barRods: [
                                          BarChartRodData(
                                            toY: (student['subjects'].values.elementAt(i) as num).toDouble(),
                                            width: 12,
                                            color: const Color(0xFFB11116),
                                          )
                                        ])
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.menu_rounded, color: Color(0xFFB11116), size: 28), onPressed: _toggleSidebar),
            const Expanded(
              child: Center(
                child: Text(
                  "Student Insights",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB11116)),
                ),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/staffDashboard', (route) => false);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFB11116), shape: BoxShape.circle, boxShadow: [
                  BoxShadow(color: Color(0x33B11116), blurRadius: 8, offset: Offset(0, 3))
                ]),
                child: const Icon(Icons.dashboard, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 8, isMobile ? 16 : 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 12),
        const Text(
          "Search Student",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB11116)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                hintText: "Enter Register Number or name",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _runFilter(_searchController.text),
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text("Search", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB11116), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ]),
        const SizedBox(height: 16),

        // Selected actions row
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _printSelected,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text("Print Selected", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB11116), minimumSize: const Size(150, 44)),
            ),
            const SizedBox(width: 12),
            Text('${selected.values.where((v) => v).length} selected'),
          ],
        ),
        const SizedBox(height: 16),

        // Students list or empty placeholder
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
            child: const Center(child: Text("No students found. Try another query.", style: TextStyle(color: Colors.black54))),
          )
        else
          Column(
            children: filtered.map((s) {
              final reg = s['regNo'] as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                child: Row(
                  children: [
                    Checkbox(value: selected[reg] ?? false, onChanged: (v) => _toggleSelect(reg, v)),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${s['regNo']} • ${s['dept']}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ]),
                    ),
                    Text('CGPA: ${s['cgpa']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _showStudentDialog(s),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFB11116)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('View', style: TextStyle(color: Color(0xFFB11116))),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 40),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/staffDashboard', (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F2FF),
        body: LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: Column(children: [
                    _buildHeader(constraints),
                    const SizedBox(height: 12),
                    Expanded(child: _buildContent(constraints)),
                  ]),
                );
              },
            ),
            IgnorePointer(
              ignoring: !_isOpen,
              child: AnimatedOpacity(
                opacity: _isOpen ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(onTap: _toggleSidebar, child: Container(color: Colors.black26)),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_sidebarTranslate.value, 0),
                  child: SizedBox(width: sidebarWidth, height: MediaQuery.of(context).size.height, child: Sidebar(role: "staff", onNavigate: _handleSidebarNavigation)),
                );
              },
            ),
          ]);
        }),
      ),
    );
  }
}
