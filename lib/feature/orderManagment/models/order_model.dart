import 'food_item_model.dart';

class Order {
  int id;
  int restaurant;
  String customerName;
  String customernumber;
  String status;
  List<FoodItem> foodItems;

  Order({
    required this.id,
    required this.customerName,
    required this.customernumber,
    required this.status,
    required this.foodItems,
    required this.restaurant,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      customernumber: json['phone'],
      restaurant: json['restaurant'],
      status: json['status'],
      foodItems: (json['order_items'] as List)
          .map((e) => FoodItem.fromJson(e))
          .toList(),
    );
  }
}
