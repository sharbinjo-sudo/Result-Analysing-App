import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/sidebar.dart';

class ClassAnalysisScreen extends StatefulWidget {
  const ClassAnalysisScreen({super.key});

  @override
  State<ClassAnalysisScreen> createState() => _ClassAnalysisScreenState();
}

class _ClassAnalysisScreenState extends State<ClassAnalysisScreen>
    with SingleTickerProviderStateMixin {
  static const double sidebarWidth = 240;
  late final AnimationController _controller;
  late final Animation<double> _sidebarTranslate;
  late final Animation<double> _contentTranslate;
  bool _isOpen = false;
  bool _navigating = false;

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

    if (ModalRoute.of(context)?.settings.name == route) {
      await _controller.reverse();
      setState(() => _isOpen = false);
      _navigating = false;
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }

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

 Widget _buildHeader(BoxConstraints constraints) {
  final double screenWidth = constraints.maxWidth;
  final bool isMobile = screenWidth < 600;

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Sidebar toggle button
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: Color(0xFFB11116), size: 28),
            onPressed: _toggleSidebar,
            tooltip: 'Menu',
          ),

          // Centered title
          Expanded(
            child: Center(
              child: Text(
                "Class Performance Analysis",
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11116),
                ),
              ),
            ),
          ),

          // Dashboard button (same)
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/staffDashboard',
                (route) => false,
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFB11116),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x33B11116),
                      blurRadius: 8,
                      offset: Offset(0, 3))
                ],
              ),
              child: const Icon(Icons.dashboard, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildContent(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;
    final double chartHeight = isMobile ? 180 : 220;
    final double barHeight = isMobile ? 240 : 280;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 8, isMobile ? 16 : 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            "Overall Class Performance",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB11116),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: SizedBox(
              height: chartHeight,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: isMobile ? 36 : 44,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: 78,
                      title: "Pass 78%",
                      radius: isMobile ? 60 : 70,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: 22,
                      title: "Fail 22%",
                      radius: isMobile ? 60 : 70,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),
          const Text(
            "Subject-wise Average Marks",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB11116),
            ),
          ),
          const SizedBox(height: 14),

          // ✅ Fixed Chart Container (with Y-axis 1–100)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: SizedBox(
              height: barHeight,
              width: double.infinity,
              child: BarChart(
                BarChartData(
                  minY: 1,
                  maxY: 100,
                  alignment: BarChartAlignment.spaceEvenly,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, _) {
                          if (value == 0) return const SizedBox.shrink();
                          if (value == 100) {
                            return const Text(
                              "100",
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const subjects = ["Maths", "DS", "OOPS", "DBMS", "CN"];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              subjects[value.toInt() % subjects.length],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 82, width: 22, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 76, width: 22, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 88, width: 22, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 91, width: 22, color: const Color(0xFFB11116))
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(toY: 79, width: 22, color: const Color(0xFFB11116))
                    ]),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),
          const Text(
            "Top Performers",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB11116),
            ),
          ),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, box) {
              final isNarrow = box.maxWidth < 700;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: isNarrow ? WrapAlignment.center : WrapAlignment.start,
                children: const [
                  TopperCard(name: "A. Karthik", regNo: "VV2025CSE003", gpa: 9.3),
                  TopperCard(name: "S. Meena", regNo: "VV2025CSE005", gpa: 9.2),
                  TopperCard(name: "R. Aravind", regNo: "VV2025CSE008", gpa: 9.1),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/staffDashboard',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F2FF), // ✅ consistent soft blue background
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(_contentTranslate.value, 0),
                      child: Column(
                        children: [
                          _buildHeader(constraints),
                          Expanded(child: _buildContent(constraints)),
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
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(_sidebarTranslate.value, 0),
                      child: SizedBox(
                        width: sidebarWidth,
                        height: MediaQuery.of(context).size.height,
                        child: Sidebar(
                          role: "staff",
                          onNavigate: _handleSidebarNavigation,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// 🔸 Top Performer Card (unchanged)
class TopperCard extends StatelessWidget {
  final String name;
  final String regNo;
  final double gpa;

  const TopperCard({
    super.key,
    required this.name,
    required this.regNo,
    required this.gpa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(1, 3)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.star, color: Color(0xFFB11116), size: 38),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            regNo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            "GPA: $gpa",
            style: const TextStyle(
              color: Color(0xFFB11116),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
