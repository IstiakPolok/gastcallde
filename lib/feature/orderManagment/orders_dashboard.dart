// lib/feature/calls/orders_dashboard.dart
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/orderManagment/controllers/order_controller.dart';
import 'package:gastcallde/feature/orderManagment/models/order_model.dart';
import 'package:gastcallde/feature/orderManagment/services/receipt_pdf_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrdersDashboard extends StatefulWidget {
  const OrdersDashboard({super.key});

  @override
  _OrdersDashboardState createState() => _OrdersDashboardState();
}

class _OrdersDashboardState extends State<OrdersDashboard> {
  final OrderController orderController = Get.find<OrderController>();
  String selectedColumn = 'incoming';
  DateTime _currentDate = DateTime.now();
  late String displayDate;

  // Helper method to get display text for status
  String getStatusDisplayText(String status) {
    switch (status) {
      case 'incoming':
        return 'incoming'.tr;
      case 'in_preparation':
        return 'in_preparation'.tr;
      case 'out_for_delivery':
        return 'out_for_delivery'.tr;
      case 'completed':
        return 'completed'.tr;
      default:
        return status;
    }
  }

  // Helper method to format date display
  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'today'.tr;
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  void _onPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      displayDate = _formatDateDisplay(_currentDate);
    });
    orderController.fetchOrders(date: _currentDate);
  }

  void _onNextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
      displayDate = _formatDateDisplay(_currentDate);
    });
    orderController.fetchOrders(date: _currentDate);
  }

  @override
  void initState() {
    super.initState();
    displayDate = _formatDateDisplay(_currentDate);
    // Fetch fresh data whenever this screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.fetchOrders(date: _currentDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the screen width is more than a threshold to identify tablets
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'order_management'.tr,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _onPreviousDay(),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              displayDate,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _onNextDay(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // If it's a phone, show the dropdown to select the column
          if (!isTablet)
            DropdownButton<String>(
              value: selectedColumn,
              onChanged: (String? newValue) {
                setState(() {
                  selectedColumn = newValue!;
                });
              },
              items:
                  <String>[
                    'incoming',
                    'in_preparation',
                    'out_for_delivery',
                    'completed',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(getStatusDisplayText(value)),
                    );
                  }).toList(),
            ),
          const SizedBox(height: 20),

          // Responsive layout
          Expanded(
            child: Obx(() {
              // Show loading indicator
              if (orderController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return isTablet
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: OrderListColumn(
                            title: 'incoming'.tr,
                            orders: orderController.incomingOrders,
                            onButtonPressed: orderController.moveToPreparation,
                            buttonText: 'in_preparation'.tr,
                            buttonColor: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OrderListColumn(
                            title: 'in_preparation'.tr,
                            orders: orderController.inPreparationOrders,
                            onButtonPressed: orderController.moveToDelivery,
                            buttonText: 'out_for_delivery'.tr,
                            buttonColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OrderListColumn(
                            title: 'out_for_delivery'.tr,
                            orders: orderController.outForDeliveryOrders,
                            onButtonPressed: orderController.moveToCompleted,
                            buttonText: 'completed'.tr,
                            buttonColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OrderListColumn(
                            title: 'completed'.tr,
                            orders: orderController.completedOrders,
                            onButtonPressed: null, // No button on this list
                            buttonText: '',
                            buttonColor: Colors.transparent,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Conditionally display the column based on the selected value
                        if (selectedColumn == 'incoming')
                          Expanded(
                            child: OrderListColumn(
                              title: 'incoming'.tr,
                              orders: orderController.incomingOrders,
                              onButtonPressed:
                                  orderController.moveToPreparation,
                              buttonText: 'in_preparation'.tr,
                              buttonColor: Colors.amber,
                            ),
                          ),
                        if (selectedColumn == 'in_preparation')
                          Expanded(
                            child: OrderListColumn(
                              title: 'in_preparation'.tr,
                              orders: orderController.inPreparationOrders,
                              onButtonPressed: orderController.moveToDelivery,
                              buttonText: 'out_for_delivery'.tr,
                              buttonColor: Colors.blue,
                            ),
                          ),
                        if (selectedColumn == 'out_for_delivery')
                          Expanded(
                            child: OrderListColumn(
                              title: 'out_for_delivery'.tr,
                              orders: orderController.outForDeliveryOrders,
                              onButtonPressed: orderController.moveToCompleted,
                              buttonText: 'completed'.tr,
                              buttonColor: Colors.green,
                            ),
                          ),
                        if (selectedColumn == 'completed')
                          Expanded(
                            child: OrderListColumn(
                              title: 'completed'.tr,
                              orders: orderController.completedOrders,
                              onButtonPressed: null, // No button on this list
                              buttonText: '',
                              buttonColor: Colors.transparent,
                            ),
                          ),
                      ],
                    );
            }),
          ),
        ],
      ),
    );
  }
}

// A reusable widget to create a column for each order status.
class OrderListColumn extends StatelessWidget {
  final String title;
  final RxList<Order> orders;
  final Function(Order)? onButtonPressed;
  final String buttonText;
  final Color buttonColor;
  final bool showDeleteButton;
  final bool
  showBackButton; // New parameter to control whether the back button is visible

  const OrderListColumn({
    super.key,
    required this.title,
    required this.orders,
    this.onButtonPressed,
    this.buttonText = '',
    this.buttonColor = Colors.grey,
    this.showDeleteButton = true,
    this.showBackButton = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (orders.isEmpty) {
              return Center(
                child: Text(
                  'no_orders'.tr,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: orders.length,
              addAutomaticKeepAlives: true,
              cacheExtent: 500, // Cache more items for smoother scrolling
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  title: title,
                  isTablet: isTablet,
                  onButtonPressed: onButtonPressed,
                  buttonText: buttonText,
                  buttonColor: buttonColor,
                  showBackButton: showBackButton,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// Separate widget for order card to improve performance
class OrderCard extends StatelessWidget {
  final Order order;
  final String title;
  final bool isTablet;
  final Function(Order)? onButtonPressed;
  final String buttonText;
  final Color buttonColor;
  final bool showBackButton;

  const OrderCard({
    super.key,
    required this.order,
    required this.title,
    required this.isTablet,
    this.onButtonPressed,
    required this.buttonText,
    required this.buttonColor,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate order total once
    final orderTotal = order.foodItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: isTablet
            ? _buildTabletView(orderTotal)
            : _buildMobileView(orderTotal),
      ),
    );
  }

  Widget _buildTabletView(double orderTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton && title != 'incoming')
          Text('${'customer'.tr}: ${order.customerName}'),
        Text('${'phone'.tr}: ${order.customernumber}'),
        const SizedBox(height: 8),
        // Iterate over the food items and display their details
        ...order.foodItems.map((foodItem) => _buildFoodItem(foodItem)),
        if (onButtonPressed != null || showBackButton) ...[
          _buildOrderSummary(orderTotal),
        ],
      ],
    );
  }

  Widget _buildMobileView(double orderTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${'customer'.tr}: ${order.customerName}'),
        Text('${'phone'.tr}: ${order.customernumber}'),
        const SizedBox(height: 8),
        ...order.foodItems.map((foodItem) => _buildFoodItem(foodItem)),
        if (onButtonPressed != null || showBackButton) ...[
          _buildOrderSummary(orderTotal),
        ],
      ],
    );
  }

  Widget _buildFoodItem(dynamic foodItem) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${'price'.tr}: \$${foodItem.price.toStringAsFixed(2)}'),
                  Text('${'quantity'.tr}: ${foodItem.quantity}'),
                  if (foodItem.extras.isNotEmpty)
                    Text(
                      '${'extras'.tr}: ${foodItem.extras}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  if (foodItem.extrasPrice > 0)
                    Text(
                      '${'extras_price'.tr}: \$${foodItem.extrasPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (foodItem.specialInstructions.isNotEmpty)
                    Text(
                      '${'special_instructions'.tr}: ${foodItem.specialInstructions}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  Text(
                    '${'total'.tr}: \$${(foodItem.price * foodItem.quantity).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildOrderSummary(double orderTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Notes
        if (order.orderNotes != null && order.orderNotes!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '${'order_notes'.tr}: ${order.orderNotes}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        // Allergy Info
        if (order.allergy != null && order.allergy!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '${'allergy'.tr}: ${order.allergy}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Subtotal
        Text(
          '${'subtotal'.tr}: \$${orderTotal.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13),
        ),
        // Delivery Fee
        if (order.deliveryAreaJson != null &&
            order.deliveryAreaJson!['delivery_fee'] != null)
          Text(
            '${'delivery_fee'.tr}: \$${order.deliveryAreaJson!['delivery_fee'].toString()}',
            style: const TextStyle(fontSize: 13),
          ),
        const SizedBox(height: 4),
        // Total Price
        Text(
          '${'total_price'.tr}: \$${order.totalPrice}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (showBackButton && title != 'incoming')
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              final controller = Get.find<OrderController>();
              controller.reverseOrderStatus(order);
            },
          ),
        if (onButtonPressed != null)
          Expanded(
            child: ElevatedButton(
              onPressed: () => onButtonPressed!(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                textAlign: TextAlign.center,
                buttonText,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        const SizedBox(width: 8),
        // Print Receipt Button - Only in Completed
        if (title == 'completed'.tr)
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.primaryColor),
            onPressed: () async {
              try {
                await ReceiptPdfService.printReceipt(order.id);
                Get.snackbar(
                  'success'.tr,
                  'receipt_opened_successfully'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
              } catch (e) {
                final errorMessage = e.toString();
                final isFileSaved = errorMessage.contains(
                  'PDF saved to Downloads',
                );

                Get.snackbar(
                  isFileSaved ? 'success'.tr : 'error'.tr,
                  isFileSaved
                      ? 'receipt_saved_to_downloads'.tr
                      : '${'failed_to_generate_receipt'.tr}: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: isFileSaved ? Colors.orange : Colors.red,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                );
              }
            },
          ),
      ],
    );
  }
}
