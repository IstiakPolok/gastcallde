import 'food_item_model.dart';

class Order {
  int id;
  int restaurant;
  String customerName;
  String customernumber;
  String status;
  List<FoodItem> foodItems;
  String? orderNotes;
  String? allergy;
  String? totalPrice;
  Map<String, dynamic>? deliveryAreaJson;

  Order({
    required this.id,
    required this.customerName,
    required this.customernumber,
    required this.status,
    required this.foodItems,
    required this.restaurant,
    this.orderNotes,
    this.allergy,
    this.totalPrice,
    this.deliveryAreaJson,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      customernumber: json['phone'],
      restaurant: json['restaurant'],
      status: json['status'],
      orderNotes: json['order_notes'],
      allergy: json['allergy'],
      totalPrice: json['total_price'],
      deliveryAreaJson: json['delivery_area_json'],
      foodItems:
          (json['order_items'] as List?)
              ?.where((e) => e != null)
              .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
