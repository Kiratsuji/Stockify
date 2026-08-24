class Movement {
  final String? id;
  final String productName;
  final String type;
  final int quantity;
  final DateTime createdAt;

  Movement({
    this.id,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'type': type,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Movement.fromMap(Map<String, dynamic> map, String documentId) {
    return Movement(
      id: documentId,
      productName: map['productName'] ?? '',
      type: map['type'] ?? 'Entrada',
      quantity: map['quantity']?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}