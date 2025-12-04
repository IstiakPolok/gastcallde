class FoodItem {
  final int id; // API item ID
  final String name;
  final double price;
  int quantity;
  final String extras; // Changed from List<String> to String
  final double extrasPrice; // Now stored as field
  final String specialInstructions;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.extras = "",
    this.extrasPrice = 0.0,
    this.specialInstructions = "",
  });

  double get totalPrice => price + extrasPrice;

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      "item": id,
      "quantity": quantity,
      "extras": extras,
      "extras_price": extrasPrice.toString(),
      "special_instructions": specialInstructions,
    };
  }

  // ✅ Factory method to create FoodItem from API JSON
  factory FoodItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('FoodItem.fromJson received null');
    }

    return FoodItem(
      id: json['item_json']?['id'] ?? 0,
      name: json['item_json']?['name'] ?? 'Unknown Item',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 1,
      extras: json['extras']?.toString() ?? "",
      extrasPrice:
          double.tryParse(json['extras_price']?.toString() ?? '0') ?? 0.0,
      specialInstructions: json['special_instructions']?.toString() ?? "",
    );
  }
}
