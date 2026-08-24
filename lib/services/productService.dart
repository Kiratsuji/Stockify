import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/productModel.dart';

class ProductService {
  final CollectionReference _productsRef =
  FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    await _productsRef.add(product.toMap());
  }

  Stream<List<Product>> getProductsStream() {
    return _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}