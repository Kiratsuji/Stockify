import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final String? category;
  final double costPrice;
  final double price;
  final int quantity;
  final int minQuantity;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    this.category,
    required this.costPrice,
    required this.price,
    required this.quantity,
    required this.minQuantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'costPrice': costPrice,
      'price': price,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'],
      costPrice: (map['costPrice'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      minQuantity: map['minQuantity'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}