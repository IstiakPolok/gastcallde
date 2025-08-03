import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// Main entry point for the application

// Convert to a StatefulWidget to manage the state of the selected filter.
class RestaurantOverviewPage extends StatefulWidget {
  const RestaurantOverviewPage({super.key});

  @override
  State<RestaurantOverviewPage> createState() => _RestaurantOverviewPageState();
}

class _RestaurantOverviewPageState extends State<RestaurantOverviewPage> {
  // A list of all available filter options.
  final List<String> _filters = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'All Data',
  ];
  // The currently selected filter, defaulting to the first one.
  String _selectedFilter = 'Last 7 Days';

  // Helper function to build the filter "buttons"
  Widget _buildFilterButton(String text) {
    final isSelected = _selectedFilter == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Update the state when a button is pressed.
          setState(() {
            _selectedFilter = text;
          });
        },
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null, // No decoration for unselected buttons.
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isSelected ? Colors.teal : Colors.blueGrey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Helper function to provide dynamic data for the top info cards.
  Map<String, String> _getInfoCardData() {
    switch (_selectedFilter) {
      case 'Last 7 Days':
        return {
          'revenueOrders': '\$45,000',
          'revenueReservation': '\$145,000',
          'callDuration': '5,320',
        };
      case 'Last 30 Days':
        return {
          'revenueOrders': '\$180,000',
          'revenueReservation': '\$580,000',
          'callDuration': '21,280',
        };
      case 'Last 90 Days':
        return {
          'revenueOrders': '\$540,000',
          'revenueReservation': '\$1,740,000',
          'callDuration': '63,840',
        };
      case 'All Data':
      default:
        return {
          'revenueOrders': '\$1,200,000',
          'revenueReservation': '\$4,500,000',
          'callDuration': '150,000',
        };
    }
  }

  // Helper function to provide dynamic data for the small info cards.
  Map<String, String> _getSmallInfoCardData() {
    switch (_selectedFilter) {
      case 'Last 7 Days':
        return {
          'numCalls': '1,250',
          'numNewCustomers': '350',
          'numReturnCustomers': '525',
          'numOrders': '875',
          'aiToHuman': '525',
        };
      case 'Last 30 Days':
        return {
          'numCalls': '5,000',
          'numNewCustomers': '1,400',
          'numReturnCustomers': '2,100',
          'numOrders': '3,500',
          'aiToHuman': '2,100',
        };
      case 'Last 90 Days':
        return {
          'numCalls': '15,000',
          'numNewCustomers': '4,200',
          'numReturnCustomers': '6,300',
          'numOrders': '10,500',
          'aiToHuman': '6,300',
        };
      case 'All Data':
      default:
        return {
          'numCalls': '35,000',
          'numNewCustomers': '9,000',
          'numReturnCustomers': '14,000',
          'numOrders': '25,000',
          'aiToHuman': '15,000',
        };
    }
  }

  // Helper function to create the non-interactive chart filter "buttons"
  Widget _buildChartFilterButton(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black87 : Colors.grey.shade600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final bool isTablet = screenWidth > breakpoint;
    final bool isMobile = screenWidth <= breakpoint;

    final infoData = _getInfoCardData();
    final smallInfoData = _getSmallInfoCardData();

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 1,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant Overview',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Live Overview of your Restaurant's",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant Overview',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Live Overview of your Restaurant's",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time range filter section
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _filters
                    .map((filter) => _buildFilterButton(filter))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Top row of info cards
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InfoCard(
                          title: 'Revenue from Orders',
                          value: infoData['revenueOrders']!,
                          subText: _selectedFilter,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InfoCard(
                          title: 'Revenue from Reservation',
                          value: infoData['revenueReservation']!,
                          subText: _selectedFilter,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InfoCard(
                          title: 'Total Call Duration(in min)',
                          value: infoData['callDuration']!,
                          subText: _selectedFilter,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: InfoCard(
                          title: 'Revenue from Orders',
                          value: infoData['revenueOrders']!,
                          subText: _selectedFilter,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: InfoCard(
                          title: 'Revenue from Reservation',
                          value: infoData['revenueReservation']!,
                          subText: _selectedFilter,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: InfoCard(
                          title: 'Total Call Duration(in min)',
                          value: infoData['callDuration']!,
                          subText: _selectedFilter,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Middle section with a mix of cards and a line chart
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column of small info cards
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            SmallInfoCard(
                              title: 'Number of Calls',
                              value: smallInfoData['numCalls']!,
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'Num of New Customers',
                              value: smallInfoData['numNewCustomers']!,
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'Num of Return Customers',
                              value: smallInfoData['numReturnCustomers']!,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Middle column of small info cards
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            SmallInfoCard(
                              title: 'Number of Orders',
                              value: smallInfoData['numOrders']!,
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'Num of Return Customers',
                              value: smallInfoData['numReturnCustomers']!,
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'AI to human staff total call',
                              value: smallInfoData['aiToHuman']!,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right column with the line chart
                      Expanded(
                        flex: 2,
                        child: ChartCard(
                          title: 'All call',
                          children: [
                            // Chart filter buttons (non-interactive)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildChartFilterButton(
                                  'All call',
                                  isSelected: true,
                                ),
                                _buildChartFilterButton('Total Order'),
                                _buildChartFilterButton('Total reservation'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Line chart widget
                            SizedBox(height: 200, child: callsLineChart()),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SmallInfoCard(
                              title: 'Number of Calls',
                              value: smallInfoData['numCalls']!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: SmallInfoCard(
                              title: 'Number of Orders',
                              value: smallInfoData['numOrders']!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: SmallInfoCard(
                              title: 'Num of New Customers',
                              value: smallInfoData['numNewCustomers']!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: SmallInfoCard(
                              title: 'Num of Return Customers',
                              value: smallInfoData['numReturnCustomers']!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SmallInfoCard(
                        title: 'AI to human staff total call',
                        value: smallInfoData['aiToHuman']!,
                      ),
                      const SizedBox(height: 24),
                      ChartCard(
                        title: 'All call',
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildChartFilterButton(
                                'All call',
                                isSelected: true,
                              ),
                              _buildChartFilterButton('Total Order'),
                              _buildChartFilterButton('Total reservation'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(height: 200, child: callsLineChart()),
                        ],
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Bottom section with two chart cards
            isTablet
                ? Row(
                    children: [
                      const Expanded(
                        child: ChartCard(
                          title: 'Total Revenue Trends',
                          children: [
                            Text(
                              '\$125,000',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(height: 200, child: RevenueLineChart()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ChartCard(
                          title: 'Total Order Quantity',
                          children: [
                            Text(
                              '1,220',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: OrderQuantityBarChart(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const ChartCard(
                        title: 'Total Revenue Trends',
                        children: [
                          Text(
                            '\$125,000',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(height: 200, child: RevenueLineChart()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ChartCard(
                        title: 'Total Order Quantity',
                        children: [
                          const Text(
                            '1,220',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(height: 200, child: OrderQuantityBarChart()),
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

// Custom widget for the large info cards
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subText;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for the smaller info cards
class SmallInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const SmallInfoCard({Key? key, required this.title, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for cards containing charts
class ChartCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ChartCard({Key? key, required this.title, required this.children})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// Widget for the line chart in the middle section
class callsLineChart extends StatelessWidget {
  const callsLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 400,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xfff3f3f3), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                switch (value.toInt()) {
                  case 0:
                    return Text('Day 1', style: style);
                  case 1:
                    return Text('Day 2', style: style);
                  case 2:
                    return Text('Day 3', style: style);
                  case 3:
                    return Text('Day 4', style: style);
                  case 4:
                    return Text('Day 5', style: style);
                  case 5:
                    return Text('Day 6', style: style);
                  case 6:
                    return Text('Day 7', style: style);
                  default:
                    return const SizedBox();
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 100:
                    return Text('100', style: GoogleFonts.inter(fontSize: 10));
                  case 200:
                    return Text('200', style: GoogleFonts.inter(fontSize: 10));
                  case 300:
                    return Text('300', style: GoogleFonts.inter(fontSize: 10));
                  case 400:
                    return Text('400', style: GoogleFonts.inter(fontSize: 10));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 190),
              FlSpot(1, 250),
              FlSpot(2, 170),
              FlSpot(3, 310),
              FlSpot(4, 180),
              FlSpot(5, 340),
              FlSpot(6, 290),
            ],
            isCurved: true,
            color: Colors.purple,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 120),
              FlSpot(1, 180),
              FlSpot(2, 160),
              FlSpot(3, 200),
              FlSpot(4, 150),
              FlSpot(5, 220),
              FlSpot(6, 210),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 300),
              FlSpot(1, 270),
              FlSpot(2, 280),
              FlSpot(3, 260),
              FlSpot(4, 290),
              FlSpot(5, 310),
              FlSpot(6, 330),
            ],
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

// Widget for the bottom-left line chart
class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 400,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xfff3f3f3), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Day 1';
                    break;
                  case 1:
                    text = 'Day 2';
                    break;
                  case 2:
                    text = 'Day 3';
                    break;
                  case 3:
                    text = 'Day 4';
                    break;
                  case 4:
                    text = 'Day 5';
                    break;
                  case 5:
                    text = 'Day 6';
                    break;
                  case 6:
                    text = 'Day 7';
                    break;
                  default:
                    return Container();
                }
                return Text(text, style: style);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 100:
                    return Text('100', style: GoogleFonts.inter(fontSize: 10));
                  case 200:
                    return Text('200', style: GoogleFonts.inter(fontSize: 10));
                  case 300:
                    return Text('300', style: GoogleFonts.inter(fontSize: 10));
                  case 400:
                    return Text('400', style: GoogleFonts.inter(fontSize: 10));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 190),
              FlSpot(1, 250),
              FlSpot(2, 170),
              FlSpot(3, 310),
              FlSpot(4, 180),
              FlSpot(5, 340),
              FlSpot(6, 290),
            ],
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.purple.shade300, Colors.purple.shade300],
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for the bottom-right bar chart
class OrderQuantityBarChart extends StatelessWidget {
  const OrderQuantityBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 400,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Day 1';
                    break;
                  case 1:
                    text = 'Day 2';
                    break;
                  case 2:
                    text = 'Day 3';
                    break;
                  case 3:
                    text = 'Day 4';
                    break;
                  case 4:
                    text = 'Day 5';
                    break;
                  case 5:
                    text = 'Day 6';
                    break;
                  case 6:
                    text = 'Day 7';
                    break;
                  default:
                    return Container();
                }
                return Text(text, style: style);
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 100:
                    return Text('100', style: GoogleFonts.inter(fontSize: 10));
                  case 200:
                    return Text('200', style: GoogleFonts.inter(fontSize: 10));
                  case 300:
                    return Text('300', style: GoogleFonts.inter(fontSize: 10));
                  case 400:
                    return Text('400', style: GoogleFonts.inter(fontSize: 10));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xfff3f3f3), strokeWidth: 1);
          },
        ),
        barGroups: [
          _buildBarGroupData(0, 200),
          _buildBarGroupData(1, 240),
          _buildBarGroupData(2, 280),
          _buildBarGroupData(3, 300),
          _buildBarGroupData(4, 270),
          _buildBarGroupData(5, 310),
          _buildBarGroupData(6, 290),
        ],
      ),
    );
  }

  // Helper function to create individual bar groups
  BarChartGroupData _buildBarGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Color(0xFFE8EDF5),
          width: 30,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
