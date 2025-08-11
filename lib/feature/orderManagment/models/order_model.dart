// lib/feature/calls/order_model.dart
import 'food_item_model.dart';

class Order {
  final String id;
  final String customerName;
  final String customernumber; // Added customer number`
  final List<FoodItem> foodItems; // This is the correct type
  String status;

  Order({
    required this.id,
    required this.customerName,
    required this.customernumber, // Initialize customer number
    required this.foodItems,
    this.status = 'Incoming',
  });
}
