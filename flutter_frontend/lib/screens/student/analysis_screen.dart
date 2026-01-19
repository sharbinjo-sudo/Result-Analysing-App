// lib/screens/student/analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/sidebar.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;
  bool _isOpen = false;
  bool _navigating = false;

  final List<FlSpot> _cgpaSpots = const [
    FlSpot(0, 7.8),
    FlSpot(1, 8.1),
    FlSpot(2, 8.3),
    FlSpot(3, 8.6),
  ];
  final List<String> _semLabels = const ["S1", "S2", "S3", "S4"];

  final List<int> _subjectMarks = [85, 92, 78, 88, 95];
  final List<String> _subjectLabels = ["Maths", "DS", "OOPS", "DBMS", "CN"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sidebarTranslate = Tween<double>(begin: -sidebarWidth, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _contentTranslate = Tween<double>(begin: 0, end: sidebarWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
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

    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      await _controller.reverse();
      if (mounted) setState(() => _isOpen = false);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🌟 Keep same header style for consistency
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: Color(0xFFB11116), size: 28),
              onPressed: _toggleSidebar,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Performance Analysis",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                ),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/studentDashboard',
                  (route) => false,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFB11116),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33B11116),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.dashboard, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Charts + layout
  Widget _buildContent() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 600;
      final double containerMaxWidth = isMobile ? constraints.maxWidth : 820;
      final double lineChartHeight = isMobile ? 220 : 260;
      final double barChartHeight = isMobile ? 220 : 300;

      final List<double> cgpaValues = _cgpaSpots.map((e) => e.y).toList();
final double minY = cgpaValues.reduce((a, b) => a < b ? a : b);
final double maxY = cgpaValues.reduce((a, b) => a > b ? a : b) + 0.2;


      final int maxBar = _subjectMarks.reduce((a, b) => a > b ? a : b);
      int barTop = ((maxBar + 24) ~/ 25) * 25;
      if (barTop < maxBar) barTop += 25;
      final int barStep = barTop <= 50 ? 10 : 25;
      final List<int> barTicks = [for (int v = 0; v <= barTop; v += barStep) v];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: containerMaxWidth),
            child: Column(
              crossAxisAlignment:
                  isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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

                // ✅ CGPA CHART
                Container(
                  height: lineChartHeight,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: _cgpaSpots.length.toDouble() - 1,
                      minY: minY,
                      maxY: maxY,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              for (final cgpa in cgpaValues) {
                                if ((value - cgpa).abs() < 0.05) {
                                  return Text(
                                    cgpa.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0) return const SizedBox.shrink();
                              final int idx = value.toInt();
                              if (idx < 0 || idx >= _semLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _semLabels[idx],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _cgpaSpots,
                          isCurved: true,
                          color: const Color(0xFFB11116),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFB11116).withOpacity(0.15),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => Colors.black87,
                          tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final cgpa = spot.y.toStringAsFixed(2);
                              final sem =
                                  _semLabels[spot.x.toInt().clamp(0, _semLabels.length - 1)];
                              return LineTooltipItem(
                                '$sem\nCGPA: $cgpa',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // 🔥 MARK COMPARISON
                const Text(
                  "Last Semester Mark Comparison",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11116),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ BAR CHART
                Container(
                  height: barChartHeight,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: barTop.toDouble(),
                      minY: 0,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      alignment: BarChartAlignment.spaceAround,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (value, meta) {
                              final nearest = barTicks.firstWhere(
                                  (t) => (value - t).abs() < 0.5,
                                  orElse: () => -1);
                              if (nearest == -1) return const SizedBox();
                              return Text(
                                nearest.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) {
                              final idx = value.round();
                              if (idx < 0 || idx >= _subjectLabels.length)
                                return const SizedBox();
                              return Text(
                                _subjectLabels[idx],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFB11116),
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: List.generate(
                        _subjectMarks.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: _subjectMarks[i].toDouble(),
                              width: isMobile ? 18 : 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB11116), Color(0xFFFF6A6A)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.black87,
                          tooltipPadding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          tooltipBorderRadius: BorderRadius.circular(6),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final idx = group.x.toInt();
                            final subj = _subjectLabels[idx];
                            final mark = _subjectMarks[idx];
                            return BarTooltipItem(
                              '$subj: $mark / 100',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/studentDashboard',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F2FF), // ✅ Unified background color
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(_contentTranslate.value, 0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                );
              },
            ),
            IgnorePointer(
              ignoring: !_isOpen,
              child: AnimatedOpacity(
                opacity: _isOpen ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _toggleSidebar,
                  child: Container(color: Colors.black26),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_sidebarTranslate.value, 0),
                  child: child,
                );
              },
              child: SizedBox(
                width: sidebarWidth,
                height: MediaQuery.of(context).size.height,
                child:
                    Sidebar(role: "student", onNavigate: _handleSidebarNavigation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
