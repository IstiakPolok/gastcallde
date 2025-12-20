class Extra {
  final int id;
  final String title;
  final String price;
  final String? updatedAt;

  Extra({
    required this.id,
    required this.title,
    required this.price,
    this.updatedAt,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['id'],
      title: json['extras'] ?? '',
      price: json['extras_price'] ?? '',
      updatedAt: json['update_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'extras': title,
      'extras_price': price,
      'update_at': updatedAt,
    };
  }
}
