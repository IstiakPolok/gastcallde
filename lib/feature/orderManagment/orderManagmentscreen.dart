import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/orderManagment/order_entry_screen.dart';
import 'package:gastcallde/feature/orderManagment/orders_dashboard.dart';
import 'package:get/get.dart';

class orderManagmentscreen extends StatelessWidget {
  orderManagmentscreen({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text(' ')) : null,
      drawer: isMobile
          ? ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return CustomDrawer(
                  selectedIndex: 2,
                  onItemSelected: (index) {
                    _selectedIndexNotifier.value = index;
                  },
                );
              },
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return CustomNavigationRail(
                    selectedIndex: 2,
                    onDestinationSelected: (index) {
                      _selectedIndexNotifier.value = index;
                    },
                  );
                },
              ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  // This is the dashboard containing the order lists
                  return OrdersDashboard();
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Example: Add a new order.
      //     // In a real app, this would come from an API.
      //     final controller = Get.find<OrderController>();
      //     controller.addOrder(
      //       Order(
      //         id: DateTime.now().millisecondsSinceEpoch.toString(),
      //         customerName: 'Customer ${controller.incomingOrders.length + 1}',
      //         foodItems: ['Burger', 'Fries', 'Coke'],
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      //   tooltip: 'Add new order',
      // ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          // Navigate to the OrderEntryScreen
          Get.to(() => OrderEntryScreen());
        },
        tooltip: 'Add new order',
        child: const Icon(Icons.add),
      ),
    );
  }
}
