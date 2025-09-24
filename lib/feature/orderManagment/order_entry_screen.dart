// lib/feature/calls/order_entry_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/orderManagment/models/food_item_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/network_caller/endpoints.dart';
import 'controllers/OrderEntryController.dart';
import 'controllers/order_controller.dart';
import 'controllers/MenuController.dart';
import 'models/order_model.dart';

class OrderEntryScreen extends StatelessWidget {
  OrderEntryScreen({super.key});

  final menuController = Get.put(Menu_Controller());
  final orderEntryController = Get.put(OrderEntryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Customer details and menu
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: orderEntryController.customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: orderEntryController.addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: orderEntryController.phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: orderEntryController.orderNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Order Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Menu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Category Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: menuController.categories.map((cat) {
                            return FilterButton(
                              text: cat,
                              onPressed: () {
                                orderEntryController.selectedCategory.value =
                                    cat;
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 10),

                  // Menu items
                  Obx(() {
                    if (menuController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = menuController.filteredItems(
                      orderEntryController.selectedCategory.value,
                    );

                    return Column(
                      children: items.map((foodItem) {
                        return FoodMenuItem(
                          id: foodItem.id,
                          name: foodItem.name,
                          price: foodItem.price,
                          onAdd: (FoodItem item) {
                            orderEntryController.addFoodItem(item);
                          },
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Right side: Current order summary
          // Right side: Current order summary
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                double total = orderEntryController.orderItems.fold(
                  0.0,
                  (sum, item) => sum + (item.totalPrice * item.quantity),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orderEntryController.orderItems.length,
                        itemBuilder: (context, index) {
                          final item = orderEntryController.orderItems[index];
                          return OrderItemSummary(
                            item: item,
                            onIncrement: () =>
                                orderEntryController.incrementQuantity(item),
                            onDecrement: () =>
                                orderEntryController.decrementQuantity(item),
                            onRemove: () =>
                                orderEntryController.removeItem(item),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Total amount display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "\$${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: orderEntryController.createOrder,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Order'),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Filter Button Widget
class FilterButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const FilterButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: Size(60, 40),
        ),
        child: Text(text),
      ),
    );
  }
}

class FoodMenuItemData {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String? image;

  FoodMenuItemData({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.image,
  });

  factory FoodMenuItemData.fromJson(Map<String, dynamic> json) {
    return FoodMenuItemData(
      id: json['id'],
      name: json['item_name'],
      category: json['category'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      description: json['descriptions'] ?? '',
      image: json['image'],
    );
  }
}

class FoodMenuItem extends StatefulWidget {
  final int id;
  final String name;
  final double price;
  final void Function(FoodItem) onAdd;

  const FoodMenuItem({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    //required this.imagePath,
    required this.onAdd,
  });

  @override
  _FoodMenuItemState createState() => _FoodMenuItemState();
}

class _FoodMenuItemState extends State<FoodMenuItem> {
  bool _baconSelected = false;
  bool _cheeseSelected = false;
  bool _avocadoSelected = false;
  bool _extraPattySelected = false;

  final TextEditingController _specialInstructionsController =
      TextEditingController(); // ✅ added

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // If the screen width is less than 600, use Column for mobile responsiveness
    bool isMobile = screenWidth < 600;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Extras',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildText('Bacon (+\$2.50)', _baconSelected, (value) {
                  setState(() {
                    _baconSelected = value!;
                  });
                }),
                _buildText('Cheese (+\$1.50)', _cheeseSelected, (value) {
                  setState(() {
                    _cheeseSelected = value!;
                  });
                }),
                _buildText('Avocado (+\$2.00)', _avocadoSelected, (value) {
                  setState(() {
                    _avocadoSelected = value!;
                  });
                }),
                const Divider(height: 1, thickness: 1),
                _buildText('Extra Patty (+\$4.00)', _extraPattySelected, (
                  value,
                ) {
                  setState(() {
                    _extraPattySelected = value!;
                  });
                }),
                const Divider(height: 1, thickness: 1),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Special Instructions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add special instructions',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout for mobile (Column)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Image.asset(widget.imagePath, width: 60, height: 60),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            widget.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '\$${widget.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
          ),
          onPressed: () {
            // Collect selected extras
            List<String> extras = [];
            if (_baconSelected) extras.add('Bacon');
            if (_cheeseSelected) extras.add('Cheese');
            if (_avocadoSelected) extras.add('Avocado');
            if (_extraPattySelected) extras.add('Extra Patty');

            widget.onAdd(
              FoodItem(
                id: widget.id,
                name: widget.name,
                price: widget.price,
                extras: extras,
                specialInstructions: _specialInstructionsController.text,
              ),
            );
          },

          child: const Text('Add to Order'),
        ),
      ],
    );
  }

  // Layout for larger screens (Row)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        //Image.asset(widget.imagePath, width: 60, height: 60),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
          ),
          onPressed: () {
            List<String> extras = [];
            double extrasPrice = 0;

            if (_baconSelected) {
              extras.add('Bacon');
              extrasPrice += 2.5;
            }
            if (_cheeseSelected) {
              extras.add('Cheese');
              extrasPrice += 1.5;
            }
            if (_avocadoSelected) {
              extras.add('Avocado');
              extrasPrice += 2.0;
            }
            if (_extraPattySelected) {
              extras.add('Extra Patty');
              extrasPrice += 4.0;
            }

            widget.onAdd(
              FoodItem(
                id: widget.id, // pass id
                name: widget.name,
                price: widget.price,
                extras: extras,

                specialInstructions: _specialInstructionsController.text,
              ),
            );
          },

          child: const Text('Add to Order'),
        ),
      ],
    );
  }

  // Checkboxes for extras
  Widget _buildText(
    String text,
    bool isChecked,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Checkbox(value: isChecked, onChanged: onChanged),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class OrderItemSummary extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const OrderItemSummary({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Check screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile =
        screenWidth < 600; // Consider mobile if width is less than 600px

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${(item.totalPrice * item.quantity).toStringAsFixed(2)}',
                  ),

                  Row(
                    children: [
                      Flexible(
                        child: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: onDecrement,
                          iconSize: 20,
                        ),
                      ),
                      Flexible(child: Text('${item.quantity}')),
                      Flexible(
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: onIncrement,

                          iconSize: 20,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${(item.totalPrice * item.quantity).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: onDecrement,
                  ),
                  Text('${item.quantity}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onIncrement,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ],
              ),
      ),
    );
  }
}
