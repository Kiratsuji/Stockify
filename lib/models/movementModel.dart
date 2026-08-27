class Movement {
  final String? id;
  final String? productId; // ID do produto associado
  final String productName;
  final String type; // 'Entrada' ou 'Saída'
  final int quantity;
  final DateTime createdAt;

  Movement({
    this.id,
    this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (productId != null) 'productId': productId,
      'productName': productName,
      'type': type,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Movement.fromMap(Map<String, dynamic> map, String documentId) {
    return Movement(
      id: documentId,
      productId: map['productId'],
      productName: map['productName'] ?? '',
      type: map['type'] ?? 'Entrada',
      quantity: map['quantity']?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}