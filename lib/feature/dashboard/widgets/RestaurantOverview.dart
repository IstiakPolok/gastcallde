import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/LanguageToggleWidget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat _formatter = DateFormat('dd MMM yy');

  @override
  void initState() {
    super.initState();

    // Fetch default stats if no dates selected
    Revenuecontroller.fetchStats(); // no dates, API will just call /owner/stats/

    // Optional: set a default last 7 days range
    DateTime today = DateTime.now();
    DateTime weekAgo = today.subtract(const Duration(days: 7));
    Revenuecontroller.fetchStats(startDate: weekAgo, endDate: today);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      // Only fetch if end date is already selected
      if (_endDate != null) {
        Revenuecontroller.fetchStats(
          startDate: _startDate!,
          endDate: _endDate!,
        );
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
      // Only fetch if start date is already selected
      if (_startDate != null) {
        Revenuecontroller.fetchStats(
          startDate: _startDate!,
          endDate: _endDate!,
        );
      }
    }
  }

  Widget _buildDateBox({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9ECFF)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF1A2E35),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              date != null ? _formatter.format(date) : label,
              style: const TextStyle(
                color: Color(0xFF1A2E35),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Select date range : ',
          style: TextStyle(
            color: Color(0xFF1A2E35),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        _buildDateBox(
          label: 'start_date'.tr,
          date: _startDate,
          onTap: () => _selectStartDate(context),
        ),
        const SizedBox(width: 12),
        Text('to'.tr, style: TextStyle(fontSize: 14, color: Color(0xFF1A2E35))),
        const SizedBox(width: 12),
        _buildDateBox(
          label: 'end_date'.tr,
          date: _endDate,
          onTap: () => _selectEndDate(context),
        ),
      ],
    );
  }

  Widget _buildChartFilterButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
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
            _buildDateRangePicker(),
            const SizedBox(height: 24),

            // Top row of info cards
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(
                          () => InfoCard(
                            title: 'total_order'.tr,
                            value:
                                "${Revenuecontroller.totalOrders.value.toStringAsFixed(2)}",
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => InfoCard(
                            title: 'Num_of_New_Customer_Order'.tr,
                            value: Revenuecontroller.numberOfNewCustomers.value
                                .toString(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => InfoCard(
                            title: 'revenue_orders'.tr,
                            value:
                                "\$${Revenuecontroller.totalRevenueOrder.value.toStringAsFixed(2)}",
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => InfoCard(
                            title: 'average_order_value'.tr,
                            value:
                                "\$${Revenuecontroller.averageOrderValue.value.toStringAsFixed(2)}",
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
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: InfoCard(
                          title: 'revenue_orders'.tr,
                          value:
                              "\$${Revenuecontroller.totalRevenueOrder.value.toStringAsFixed(2)}",
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: InfoCard(
                          title: 'Num_of_New_Customer_Order'.tr,
                          value: Revenuecontroller
                              .totalNumberOfReservations
                              .value
                              .toString(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: InfoCard(
                          title: 'total_call_duration'.tr,
                          value:
                              "${Revenuecontroller.numberOfNewCustomers.value} sec",
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
                          crossAxisAlignment: CrossAxisAlignment
                              .stretch, // makes children full width
                          children: [
                            SmallInfoCard(
                              title: 'num_returning_customer_orders'.tr,
                              value:
                                  "${Revenuecontroller.numberOfReturnCustomers.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'num_reservations'.tr,
                              value:
                                  "${Revenuecontroller.totalNumberOfReservations.value} ",
                            ),
                            const SizedBox(height: 16),

                            SmallInfoCard(
                              title: 'returning_customer_reservation_count'.tr,
                              value:
                                  "${Revenuecontroller.numberOfReturningReservations.value} ",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),
                      // Middle column of small info cards
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SmallInfoCard(
                              title: 'num_orders'.tr,
                              value:
                                  "${Revenuecontroller.numberOfNewCustomers.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'new_customer_reservation'.tr,
                              value:
                                  "${Revenuecontroller.numberOfNewReservations.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'new_customer_reservation%'.tr,
                              value:
                                  "${Revenuecontroller.newCustomerReservationPercentage.value} ",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SmallInfoCard(
                              title: 'returning_customer_order'.tr,
                              value:
                                  "${Revenuecontroller.numberOfReturningReservations.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'num_reserved_guests'.tr,
                              value:
                                  "${Revenuecontroller.totalReservationGuests.value} ",
                            ),
                            const SizedBox(height: 16),
                            SmallInfoCard(
                              title: 'returning_customer_reservation'.tr,
                              value:
                                  "${Revenuecontroller.returningCustomerReservationPercentage.value} ",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ChartCard(
                          title: 'all_call'.tr,
                          children: [
                            // Chart filter buttons (non-interactive)
                            Wrap(
                              spacing: 8, // horizontal space between buttons
                              runSpacing: 4,
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
                              value:
                                  "${Revenuecontroller.averageOrderValue.value} ",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: SmallInfoCard(
                              title: 'num_orders'.tr,
                              value:
                                  "${Revenuecontroller.numberOfNewCustomers.value} ",
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

  const InfoCard({super.key, required this.title, required this.value});

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
