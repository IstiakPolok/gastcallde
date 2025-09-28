import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/LanguageToggleWidget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/const/app_colors.dart';
import '../controllers/RestaurantOverviewController.dart';
import 'OrdersBarChart.dart';
import 'RevenueController.dart';
import 'RevenueLineChart.dart';
import 'callsLineChart.dart';

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

  @override
  void initState() {
    super.initState();
    Revenuecontroller.fetchStats(days: 7); // Default to last 7 days
  }

  // The currently selected filter, defaulting to the first one.
  String _selectedFilter = 'Last 7 Days';

  // Helper function to build the filter "buttons"
  Widget _buildFilterButton(String text) {
    final isSelected = _selectedFilter == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = text;
          });

          int days = 7;
          if (text == 'Last 30 Days') days = 30;
          if (text == 'Last 90 Days') days = 90;
          if (text == 'All Data') ; // 0 can mean "all" if API supports it

          Revenuecontroller.fetchStats(days: days);
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

  // Helper function to create the non-interactive chart filter "buttons"
  Widget _buildChartFilterButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  final RevenueController controller = Get.put(RevenueController());
  final RevenueOverviewController Revenuecontroller = Get.put(
    RevenueOverviewController(),
  );
  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final bool isTablet = screenWidth > breakpoint;
    final bool isMobile = screenWidth <= breakpoint;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 1,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'restaurant_overview'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'live_overview'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'restaurant_overview'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'live_overview'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  LanguageToggleButton(),
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
                      // Expanded(
                      //   child: InfoCard(
                      //     title: 'revenue_orders'.tr,
                      //     value: infoData['revenueOrders']!,
                      //     subText: _selectedFilter,
                      //   ),
                      // ),
                      // const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: Obx(
                          () => InfoCard(
                            title: 'revenue_orders'.tr,
                            value:
                                "\$${Revenuecontroller.totalRevenueOrder.value.toStringAsFixed(2)}",
                            subText: _selectedFilter,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: Obx(
                          () => InfoCard(
                            title: 'revenue_reservation'.tr,
                            value: Revenuecontroller
                                .totalNumberOfReservations
                                .value
                                .toString(),
                            subText: _selectedFilter,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: Obx(
                          () => InfoCard(
                            title: 'total_call_duration'.tr,
                            value:
                                "${Revenuecontroller.totalDurationSeconds.value} sec",
                            subText: _selectedFilter,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: InfoCard(
                          title: 'revenue_orders'.tr,
                          value:
                              "\$${Revenuecontroller.totalRevenueOrder.value.toStringAsFixed(2)}",

                          subText: _selectedFilter,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: InfoCard(
                          title: 'revenue_reservation'.tr,
                          value: Revenuecontroller
                              .totalNumberOfReservations
                              .value
                              .toString(),
                          subText: _selectedFilter,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: InfoCard(
                          title: 'total_call_duration'.tr,
                          value:
                              "${Revenuecontroller.totalDurationSeconds.value} sec",
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
                              title: 'num_calls'.tr,
                              value: "${Revenuecontroller.totalCalls.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'num_new_customers'.tr,
                              value:
                                  "${Revenuecontroller.numberOfNewCustomers.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'num_reservations'.tr,
                              value:
                                  "${Revenuecontroller.totalNumberOfReservations.value} ",
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
                              title: 'num_orders'.tr,
                              value:
                                  "${Revenuecontroller.totalNumberOfOrders.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'num_return_customers'.tr,
                              value:
                                  "${Revenuecontroller.numberOfReturnCustomers.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'ai_to_human'.tr,
                              value:
                                  "${Revenuecontroller.numberOfNewCustomers.value} ",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right column with the line chart
                      Expanded(
                        flex: 2,
                        child: ChartCard(
                          title: 'all_call'.tr,
                          children: [
                            // Chart filter buttons (non-interactive)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildChartFilterButton(
                                  'total_order'.tr,
                                  Colors.green,
                                ),
                                _buildChartFilterButton(
                                  'total_reservation'.tr,
                                  Colors.blue,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Line chart widget
                            SizedBox(height: 200, child: CallsLineChart()),
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
                              title: 'num_calls'.tr,
                              value: "${Revenuecontroller.totalCalls.value} ",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: SmallInfoCard(
                              title: 'num_orders'.tr,
                              value:
                                  "${Revenuecontroller.totalNumberOfOrders.value} ",
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
                              title: 'num_new_customers'.tr,
                              value:
                                  "${Revenuecontroller.numberOfNewCustomers.value} ",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: SmallInfoCard(
                              title: 'num_return_customers'.tr,
                              value:
                                  "${Revenuecontroller.numberOfReturnCustomers.value} ",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SmallInfoCard(
                        title: 'ai_to_human'.tr,
                        value:
                            "${Revenuecontroller.numberOfReturnCustomers.value} ",
                      ),
                      const SizedBox(height: 24),
                      ChartCard(
                        title: 'all_call'.tr,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildChartFilterButton(
                                'total_order'.tr,
                                Colors.green,
                              ),
                              _buildChartFilterButton(
                                'total_reservation'.tr,
                                Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(height: 200, child: CallsLineChart()),
                        ],
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Bottom section with two chart cards
            // Bottom section with two chart cards
            isTablet
                ? Row(
                    children: [
                      Expanded(
                        child: ChartCard(
                          title: 'total_revenue_trends'.tr,
                          children: [
                            Obx(
                              () => Text(
                                '\$${controller.totalRevenue.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(height: 200, child: RevenueLineChart()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ChartCard(
                          title: 'total_order_quantity'.tr,
                          children: [
                            Obx(
                              () => Text(
                                '${controller.totalOrders.value}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(height: 200, child: OrdersBarChart()),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ChartCard(
                        title: 'total_revenue_trends'.tr,
                        children: [
                          Obx(
                            () => Text(
                              '\$${controller.totalRevenue.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(height: 200, child: RevenueLineChart()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ChartCard(
                        title: 'total_order_quantity'.tr,
                        children: [
                          Obx(
                            () => Text(
                              controller.totalOrders.value.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(height: 200, child: OrdersBarChart()),
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
    super.key,
    required this.title,
    required this.value,
    required this.subText,
  });

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

  const SmallInfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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

class ChartCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ChartCard({super.key, required this.title, required this.children});

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
