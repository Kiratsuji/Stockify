class Product {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final int minQuantity;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.minQuantity = 5,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'minQuantity': minQuantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      minQuantity: map['minQuantity']?.toInt() ?? 5,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}