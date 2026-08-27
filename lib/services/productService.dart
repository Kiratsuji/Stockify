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

  Future<Product?> getProductById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateProductQuantity(String id, int newQuantity) async {
    await _productsRef.doc(id).update({'quantity': newQuantity});
  }
}