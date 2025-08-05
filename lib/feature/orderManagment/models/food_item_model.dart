// lib/feature/calls/food_item_model.dart
class FoodItem {
  final String name;
  final double price;
  int quantity;

  FoodItem({required this.name, required this.price, this.quantity = 1});
}



// class Order {
//   final String id;
//   final String customerName;
//   final List<FoodItem> foodItems; // Changed to List<FoodItem>
//   String status;

//   Order({
//     required this.id,
//     required this.customerName,
//     required this.foodItems,
//     this.status = 'Incoming',
//   });
// }