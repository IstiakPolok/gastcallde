class FoodItem {
  final int id; // API item ID
  final String name;
  final double price;
  int quantity;
  final List<String> extras;
  final String specialInstructions; // new field

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.extras = const [],
    this.specialInstructions = "",
  });

  // Calculate extra prices
  double get extrasPrice {
    double total = 0;
    for (var extra in extras) {
      switch (extra) {
        case 'Bacon':
          total += 2.5;
          break;
        case 'Cheese':
          total += 1.5;
          break;
        case 'Avocado':
          total += 2.0;
          break;
        case 'Extra Patty':
          total += 4.0;
          break;
      }
    }
    return total;
  }

  double get totalPrice => price + extrasPrice;

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      "item": id,
      "quantity": quantity,
      "extras": extras.join(", "),
      "extras_price": extrasPrice,
      "special_instructions": specialInstructions,
    };
  }

  // ✅ Factory method to create FoodItem from API JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['item']['id'],
      name: json['item']['item_name'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: json['quantity'],
      extras:
          (json['extras'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          [],
      specialInstructions: json['special_instructions'] ?? "",
    );
  }
}
