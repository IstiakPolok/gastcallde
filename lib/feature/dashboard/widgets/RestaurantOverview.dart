import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/LanguageToggleWidget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  String _selectedFilter = 'Today';

  final DateFormat _formatter = DateFormat('dd MMM yy');

  @override
  void initState() {
    super.initState();

    // Set Today as default filter
    _applyFilter('Today');
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      DateTime now = DateTime.now();

      switch (filter) {
        case 'Today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'This week':
          int weekday = now.weekday;
          _startDate = now.subtract(Duration(days: weekday - 1));
          _startDate = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
          );
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Last week':
          int weekday = now.weekday;
          DateTime startOfThisWeek = now.subtract(Duration(days: weekday - 1));
          _startDate = startOfThisWeek.subtract(const Duration(days: 7));
          _startDate = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
          );
          _endDate = startOfThisWeek.subtract(const Duration(days: 1));
          _endDate = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
            23,
            59,
            59,
          );
          break;
        case 'This month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Last month':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'Custom':
          // Don't change dates, user will select manually
          return;
      }

      // Fetch stats with the new date range
      if (_startDate != null && _endDate != null) {
        Revenuecontroller.fetchStats(
          startDate: _startDate!,
          endDate: _endDate!,
        );
      }
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _selectedFilter = 'Custom';
      });
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
      setState(() {
        _endDate = picked;
        _selectedFilter = 'Custom';
      });
      // Only fetch if start date is already selected
      if (_startDate != null) {
        Revenuecontroller.fetchStats(
          startDate: _startDate!,
          endDate: _endDate!,
        );
      }
    }
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9ECFF)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A2E35)),
          style: const TextStyle(
            color: Color(0xFF1A2E35),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: const [
            DropdownMenuItem(value: 'Today', child: Text('Today')),
            DropdownMenuItem(value: 'This week', child: Text('This week')),
            DropdownMenuItem(value: 'Last week', child: Text('Last week')),
            DropdownMenuItem(value: 'This month', child: Text('This month')),
            DropdownMenuItem(value: 'Last month', child: Text('Last month')),
            DropdownMenuItem(value: 'Custom', child: Text('Custom')),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              _applyFilter(newValue);
            }
          },
        ),
      ),
    );
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
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final bool isMobile = screenWidth <= breakpoint;

    if (isMobile) {
      // MOBILE VIEW: show in column
      return Column(
        children: [
          _buildFilterDropdown(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateBox(
                label: 'start_date'.tr,
                date: _startDate,
                onTap: () => _selectStartDate(context),
              ),
              const SizedBox(width: 12),
              Text(
                'to'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A2E35),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              _buildDateBox(
                label: 'end_date'.tr,
                date: _endDate,
                onTap: () => _selectEndDate(context),
              ),
            ],
          ),
        ],
      );
    } else {
      // TABLET/DESKTOP VIEW: show in row
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterDropdown(),
          const SizedBox(width: 24),
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
          Text(
            'to'.tr,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A2E35)),
          ),
          const SizedBox(width: 12),
          _buildDateBox(
            label: 'end_date'.tr,
            date: _endDate,
            onTap: () => _selectEndDate(context),
          ),
        ],
      );
    }
  }

  Widget _buildChartFilterButton(String text, Color color) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 4),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: isMobile ? 10 : 12,
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
          ? null
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
            _buildDateRangePicker(),
            const SizedBox(height: 24),

            // MOBILE: Info cards in a horizontal scrollable row
            if (isMobile)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => InfoCard(
                            title: 'total_order'.tr,
                            value: Revenuecontroller.totalOrders.value
                                .toStringAsFixed(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Obx(
                          () => InfoCard(
                            title: 'Num_of_New_Customer_Order'.tr,
                            value: Revenuecontroller.numberOfNewCustomers.value
                                .toString(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(
                          () => InfoCard(
                            title: 'revenue_orders'.tr,
                            value:
                                "€${Revenuecontroller.totalRevenueOrder.value.toStringAsFixed(2)}",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Obx(
                          () => InfoCard(
                            title: 'average_order_value'.tr,
                            value:
                                "€${Revenuecontroller.averageOrderValue.value.toStringAsFixed(2)}",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (isMobile) const SizedBox(height: 24),

            // MOBILE: Small info cards in a grid
            if (isMobile)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  Obx(
                    () => SmallInfoCard(
                      title: 'num_returning_customer_orders'.tr,
                      value: Revenuecontroller.numberOfReturnCustomers.value
                          .toString(),
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'num_reservations'.tr,
                      value: Revenuecontroller.totalNumberOfReservations.value
                          .toString(),
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'returning_customer_reservation_count'.tr,
                      value: Revenuecontroller
                          .numberOfReturningReservations
                          .value
                          .toString(),
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'num_orders'.tr,
                      value: '${Revenuecontroller.numberOfNewCustomers.value}%',
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'new_customer_reservation'.tr,
                      value: Revenuecontroller.numberOfNewReservations.value
                          .toString(),
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'new_customer_reservation%'.tr,
                      value:
                          '${Revenuecontroller.newCustomerReservationPercentage.value}%',
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'returning_customer_order'.tr,
                      value:
                          '${Revenuecontroller.numberOfReturningReservations.value}%',
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'num_reserved_guests'.tr,
                      value: Revenuecontroller.totalReservationGuests.value
                          .toString(),
                    ),
                  ),
                  Obx(
                    () => SmallInfoCard(
                      title: 'returning_customer_reservation'.tr,
                      value:
                          '${Revenuecontroller.returningCustomerReservationPercentage.value}%',
                    ),
                  ),
                ],
              ),

            if (isMobile) const SizedBox(height: 24),

            // MOBILE: Chart card
            if (isMobile)
              ChartCard(
                title: 'all_call'.tr,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildChartFilterButton('total_order'.tr, Colors.green),
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

            if (isMobile) const SizedBox(height: 24),

            // MOBILE: Revenue and order charts
            if (isMobile)
              ChartCard(
                title: 'total_revenue_trends'.tr,
                children: [
                  Obx(
                    () => Text(
                      '€${controller.totalRevenue.value.toStringAsFixed(2)}',
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

            if (isMobile) const SizedBox(height: 16),

            if (isMobile)
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

            // TABLET: Use original layout
            if (isTablet) ...[
              // ...existing code for tablet view (unchanged)...
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => InfoCard(
                        title: 'total_order'.tr,
                        value: Revenuecontroller.totalOrders.value
                            .toStringAsFixed(2),
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
                            "€${Revenuecontroller.totalRevenueOrder.value.toStringAsFixed(2)}",
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => InfoCard(
                        title: 'average_order_value'.tr,
                        value:
                            "€${Revenuecontroller.averageOrderValue.value.toStringAsFixed(2)}",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ...existing code for small info cards and charts...
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Obx(
                          () => SmallInfoCard(
                            title: 'num_returning_customer_orders'.tr,
                            value: Revenuecontroller
                                .numberOfReturnCustomers
                                .value
                                .toString(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => SmallInfoCard(
                            title: 'num_reservations'.tr,
                            value: Revenuecontroller
                                .totalNumberOfReservations
                                .value
                                .toString(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => SmallInfoCard(
                            title: 'returning_customer_reservation_count'.tr,
                            value: Revenuecontroller
                                .numberOfReturningReservations
                                .value
                                .toString(),
                          ),
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
                        Obx(
                          () => SmallInfoCard(
                            title: 'num_orders'.tr,
                            value:
                                '${Revenuecontroller.newCustomerOrderPercentage.value}%',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => SmallInfoCard(
                            title: 'new_customer_reservation'.tr,
                            value: Revenuecontroller
                                .numberOfNewReservations
                                .value
                                .toString(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => SmallInfoCard(
                            title: 'new_customer_reservation%'.tr,
                            value:
                                '${Revenuecontroller.newCustomerReservationPercentage.value}%',
                          ),
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
                        Obx(
                          () => SmallInfoCard(
                            title: 'returning_customer_order'.tr,
                            value:
                                '${Revenuecontroller.returningCustomerOrderPercentage.value}%',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => SmallInfoCard(
                            title: 'num_reserved_guests'.tr,
                            value: Revenuecontroller
                                .totalReservationGuests
                                .value
                                .toString(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => SmallInfoCard(
                            title: 'returning_customer_reservation'.tr,
                            value:
                                '${Revenuecontroller.returningCustomerReservationPercentage.value}%',
                          ),
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
                        Wrap(
                          spacing: 8,
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
                        SizedBox(height: 200, child: CallsLineChart()),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ChartCard(
                      title: 'total_revenue_trends'.tr,
                      children: [
                        Obx(
                          () => Text(
                            '€${controller.totalRevenue.value.toStringAsFixed(2)}',
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
                  ),
                ],
              ),
            ],
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 600;

    return Container(
      width: isMobile ? null : 200,
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
