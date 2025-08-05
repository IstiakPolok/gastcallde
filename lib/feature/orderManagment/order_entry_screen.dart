// lib/feature/calls/order_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/orderManagment/models/food_item_model.dart';
import 'package:get/get.dart';
import 'controllers/order_controller.dart';
import 'models/order_model.dart';

// Local controller for this screen to manage temporary state
class OrderEntryController extends GetxController {
  final orderItems = <FoodItem>[].obs;
  final customerNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final orderNotesController = TextEditingController();

  var selectedCategory = 'All'.obs; // Track selected category for filtering

  void addFoodItem(FoodItem item) {
    // Check if the item already exists in the current order
    var existingItemIndex = orderItems.indexWhere((i) => i.name == item.name);
    if (existingItemIndex != -1) {
      orderItems[existingItemIndex].quantity++;
      orderItems.refresh(); // Manually refresh the list to update the UI
    } else {
      orderItems.add(item);
    }
  }

  void incrementQuantity(FoodItem item) {
    item.quantity++;
    orderItems.refresh();
  }

  void decrementQuantity(FoodItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      orderItems.remove(item);
    }
    orderItems.refresh();
  }

  void removeItem(FoodItem item) {
    orderItems.remove(item);
  }

  void createOrder() {
    if (orderItems.isEmpty ||
        customerNameController.text.isEmpty ||
        addressController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add food items, customer name, and address.',
      );
      return;
    }

    // Get the global OrderController
    final orderController = Get.find<OrderController>();

    // Create a new order object
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: customerNameController.text,
      foodItems: List<FoodItem>.from(orderItems),
      customernumber: phoneController.text,
    );

    // Add the new order to the incoming list
    orderController.addOrder(newOrder);

    // Clear the form and close the screen
    clearForm();
    Get.back();
  }

  void clearForm() {
    customerNameController.clear();
    addressController.clear();
    phoneController.clear();
    orderNotesController.clear();
    orderItems.clear();
  }
}

// Change the `filteredFoodItems` to use an Obx widget to reactively update
class OrderEntryScreen extends StatelessWidget {
  OrderEntryScreen({super.key});

  final orderEntryController = Get.put(OrderEntryController());

  // List of food items categorized by type
  final List<FoodMenuItemData> allFoodItems = [
    FoodMenuItemData(
      name: 'burger',
      price: 12.99,
      imagePath: 'assets/image/burger.png',
      category: 'Burger',
    ),
    FoodMenuItemData(
      name: 'Pizza',
      price: 15.50,
      imagePath: 'assets/image/pizza.png',
      category: 'Pizza',
    ),
    // Add more items as needed
  ];

  // Filter food items based on selected category
  List<FoodMenuItemData> get filteredFoodItems {
    if (orderEntryController.selectedCategory.value == 'All') {
      return allFoodItems;
    } else {
      return allFoodItems
          .where(
            (item) =>
                item.category == orderEntryController.selectedCategory.value,
          )
          .toList();
    }
  }

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FilterButton(
                          text: 'All',
                          onPressed: () {
                            orderEntryController.selectedCategory.value = 'All';
                          },
                        ),
                        FilterButton(
                          text: 'Pizza',
                          onPressed: () {
                            orderEntryController.selectedCategory.value =
                                'Pizza';
                          },
                        ),
                        FilterButton(
                          text: 'Burger',
                          onPressed: () {
                            orderEntryController.selectedCategory.value =
                                'Burger';
                          },
                        ),
                        FilterButton(
                          text: 'Dessert',
                          onPressed: () {
                            orderEntryController.selectedCategory.value =
                                'Dessert';
                          },
                        ),
                        FilterButton(
                          text: 'Drink',
                          onPressed: () {
                            orderEntryController.selectedCategory.value =
                                'Drink';
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  // Use Obx to make this section reactive
                  Obx(() {
                    return Column(
                      children: filteredFoodItems.map((foodItem) {
                        return FoodMenuItem(
                          name: foodItem.name,
                          price: foodItem.price,
                          imagePath: foodItem.imagePath,
                          onAdd: () {
                            orderEntryController.addFoodItem(
                              FoodItem(
                                name: foodItem.name,
                                price: foodItem.price,
                              ),
                            );
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
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Column(
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
                ),
              ),
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
  final String name;
  final double price;
  final String imagePath;
  final String category; // This will hold the category for filtering

  FoodMenuItemData({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
  });
}

class FoodMenuItem extends StatefulWidget {
  final String name;
  final double price;
  final String imagePath;
  final VoidCallback onAdd;

  const FoodMenuItem({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
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
        Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(widget.imagePath, width: 60, height: 60),
        ),
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
          onPressed: widget.onAdd,
          child: const Text('Add to Order'),
        ),
      ],
    );
  }

  // Layout for larger screens (Row)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Image.asset(widget.imagePath, width: 60, height: 60),
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
          onPressed: widget.onAdd,
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
                  Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
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
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
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
