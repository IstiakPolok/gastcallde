// lib/feature/calls/orders_dashboard.dart
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/orderManagment/controllers/order_controller.dart';
import 'package:gastcallde/feature/orderManagment/models/order_model.dart';
import 'package:get/get.dart';

class OrdersDashboard extends StatefulWidget {
  const OrdersDashboard({super.key});

  @override
  _OrdersDashboardState createState() => _OrdersDashboardState();
}

class _OrdersDashboardState extends State<OrdersDashboard> {
  final OrderController orderController = Get.find<OrderController>();
  String selectedColumn = 'Incoming';

  @override
  Widget build(BuildContext context) {
    // Check if the screen width is more than a threshold to identify tablets
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

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
                    'Incoming',
                    'In Preparation',
                    'Out for Delivery',
                    'Completed',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
          const SizedBox(height: 20),

          // Responsive layout
          Expanded(
            child: isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: OrderListColumn(
                          title: 'Incoming',
                          orders: orderController.incomingOrders,
                          onButtonPressed: orderController.moveToPreparation,
                          buttonText: 'In Preparation',
                          buttonColor: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OrderListColumn(
                          title: 'In Preparation',
                          orders: orderController.inPreparationOrders,
                          onButtonPressed: orderController.moveToDelivery,
                          buttonText: 'Out for Delivery',
                          buttonColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OrderListColumn(
                          title: 'Out for Delivery',
                          orders: orderController.outForDeliveryOrders,
                          onButtonPressed: orderController.moveToCompleted,
                          buttonText: 'Completed',
                          buttonColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OrderListColumn(
                          title: 'Completed',
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
                      if (selectedColumn == 'Incoming')
                        Expanded(
                          child: OrderListColumn(
                            title: 'Incoming',
                            orders: orderController.incomingOrders,
                            onButtonPressed: orderController.moveToPreparation,
                            buttonText: 'In Preparation',
                            buttonColor: Colors.amber,
                          ),
                        ),
                      if (selectedColumn == 'In Preparation')
                        Expanded(
                          child: OrderListColumn(
                            title: 'In Preparation',
                            orders: orderController.inPreparationOrders,
                            onButtonPressed: orderController.moveToDelivery,
                            buttonText: 'Out for Delivery',
                            buttonColor: Colors.blue,
                          ),
                        ),
                      if (selectedColumn == 'Out for Delivery')
                        Expanded(
                          child: OrderListColumn(
                            title: 'Out for Delivery',
                            orders: orderController.outForDeliveryOrders,
                            onButtonPressed: orderController.moveToCompleted,
                            buttonText: 'Completed',
                            buttonColor: Colors.green,
                          ),
                        ),
                      if (selectedColumn == 'Completed')
                        Expanded(
                          child: OrderListColumn(
                            title: 'Completed',
                            orders: orderController.completedOrders,
                            onButtonPressed: null, // No button on this list
                            buttonText: '',
                            buttonColor: Colors.transparent,
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
          child: Obx(
            () => ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderTotal = order.foodItems.fold<double>(
                  0,
                  (sum, item) => sum + (item.price * item.quantity),
                );
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isTablet
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer: ${order.customerName}'),
                              Text('Phone: ${order.customernumber}'),
                              const SizedBox(height: 8),
                              // Iterate over the food items and display their details
                              for (var foodItem in order.foodItems) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            foodItem.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Price: \$${foodItem.price.toStringAsFixed(2)}',
                                          ),
                                          Text(
                                            'Quantity: ${foodItem.quantity}',
                                          ),
                                          Text(
                                            'Total: \$${(foodItem.price * foodItem.quantity).toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                              ],
                              if (onButtonPressed != null ||
                                  showDeleteButton ||
                                  showBackButton) ...[
                                Column(
                                  children: [
                                    Text(
                                      'Order Total: \$${orderTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    // Back button
                                    if (onButtonPressed != null)
                                      ElevatedButton(
                                        onPressed: () =>
                                            onButtonPressed!(order),
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

                                    // Delete button
                                    Row(
                                      children: [
                                        // Inside the Row where the back button is shown
                                        if (showBackButton &&
                                            title !=
                                                'Incoming') // <-- Hide when Incoming
                                          IconButton(
                                            icon: const Icon(
                                              Icons.arrow_back_ios,
                                              color: AppColors.primaryColor,
                                            ),
                                            onPressed: () {
                                              final controller =
                                                  Get.find<OrderController>();
                                              controller.reverseOrderStatus(
                                                order,
                                              );
                                            },
                                          ),

                                        Spacer(),
                                        if (showDeleteButton) ...[
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_sharp,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              final controller =
                                                  Get.find<OrderController>();
                                              controller.deleteOrder(order);
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer: ${order.customerName}'),
                              Text('Phone: ${order.customernumber}'),
                              const SizedBox(height: 8),
                              // Iterate over the food items and display their details
                              for (var foodItem in order.foodItems) ...[
                                Row(
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/image/${foodItem.name.toLowerCase().replaceAll(' ', '_')}.png', // Assuming your images are named based on food item names
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Display the food item details (name, price, quantity, total price)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            foodItem.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Price: \$${foodItem.price.toStringAsFixed(2)}',
                                          ),
                                          Text(
                                            'Quantity: ${foodItem.quantity}',
                                          ),
                                          Text(
                                            'Total: \$${(foodItem.price * foodItem.quantity).toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                              ],
                              if (onButtonPressed != null ||
                                  showDeleteButton ||
                                  showBackButton) ...[
                                Row(
                                  children: [
                                    if (showBackButton)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          final controller =
                                              Get.find<OrderController>();
                                          controller.reverseOrderStatus(
                                            order,
                                          ); // Reverse order status when back button is pressed
                                        },
                                      ),
                                    if (onButtonPressed != null)
                                      ElevatedButton(
                                        onPressed: () =>
                                            onButtonPressed!(order),
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
                                    Spacer(),
                                    if (showDeleteButton) ...[
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_sharp,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          final controller =
                                              Get.find<OrderController>();
                                          controller.deleteOrder(order);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
