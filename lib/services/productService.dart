import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/productModel.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Busca o ID da empresa vinculada ao usuário logado
  Future<String?> _getCompanyId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _db.collection('users').doc(user.uid).get();
    return userDoc.data()?['companyId'] as String?;
  }

  // Retorna a referência da subcoleção de produtos da empresa
  Future<CollectionReference?> _getProductsRef() async {
    final companyId = await _getCompanyId();
    if (companyId == null) return null;
    return _db.collection('companies').doc(companyId).collection('products');
  }

  // Adiciona produto na subcoleção da empresa
  Future<void> addProduct(Product product) async {
    final ref = await _getProductsRef();
    if (ref == null) throw Exception('Empresa não encontrada.');
    await ref.add(product.toMap());
  }

  // Escuta produtos apenas da empresa logada
  Stream<List<Product>> getProductsStream() async* {
    final ref = await _getProductsRef();
    if (ref == null) {
      yield [];
      return;
    }

    yield* ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Busca produto por ID
  Future<Product?> getProductById(String id) async {
    final ref = await _getProductsRef();
    if (ref == null) return null;

    final doc = await ref.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Atualiza quantidade
  Future<void> updateProductQuantity(String id, int newQuantity) async {
    final ref = await _getProductsRef();
    if (ref == null) throw Exception('Empresa não encontrada.');
    await ref.doc(id).update({'quantity': newQuantity});
  }
}