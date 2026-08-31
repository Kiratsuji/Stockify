import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Caracteres sem ambiguidade visual (sem 0/O, 1/I, etc.)
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateInviteCode() {
    final rand = Random.secure();
    return List.generate(6, (_) => _codeChars[rand.nextInt(_codeChars.length)])
        .join();
  }

  Future<String?> getCompanyId() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['companyId'] as String?;
  }

  // Cria a empresa com os dados coletados no wizard (steps 1-3) e as
  // categorias criadas durante o onboarding, e já vincula o usuário atual
  // como dono. Retorna o ID da empresa criada.
  Future<String> createCompany({
    required Map<String, dynamic> companyData,
    List<String> categories = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    String inviteCode = _generateInviteCode(); // gere o código de convite

    final companyRef = _db.collection('companies').doc();
    final userRef = _db.collection('users').doc(user.uid);

    // Executa em lote (Batch)
    final batch = _db.batch();

    batch.set(companyRef, {
      ...companyData,
      'ownerId': user.uid,
      'inviteCode': inviteCode,
      'categories': categories,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(userRef, {
      'companyId': companyRef.id,
    }, SetOptions(merge: true));

    await batch.commit();

    return companyRef.id;
  }

  // Vincula o usuário atual a uma empresa existente através do código de convite
  Future<void> joinCompany(String inviteCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    final normalizedCode = inviteCode.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw Exception('Informe um código de convite.');
    }

    final query = await _db
        .collection('companies')
        .where('inviteCode', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Nenhuma empresa encontrada com esse código.');
    }

    final companyDoc = query.docs.first;

    await _db.collection('users').doc(user.uid).set({
      'companyId': companyDoc.id,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getCurrentCompany() async {
    final companyId = await getCompanyId();
    if (companyId == null) return null;
    final doc = await _db.collection('companies').doc(companyId).get();
    return doc.data();
  }

  // Stream das categorias da empresa logada — fonte única de verdade,
  // substitui listas locais que se perdiam ao trocar de tela.
  Stream<List<String>> getCategoriesStream() async* {
    final companyId = await getCompanyId();
    if (companyId == null) {
      yield [];
      return;
    }

    yield* _db.collection('companies').doc(companyId).snapshots().map((snap) {
      final data = snap.data();
      final rawCategories = data?['categories'];
      if (rawCategories == null) return <String>[];
      return List<String>.from(rawCategories);
    });
  }

  Future<void> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;

    final companyId = await getCompanyId();
    if (companyId == null) throw Exception('Empresa não encontrada.');

    await _db.collection('companies').doc(companyId).update({
      'categories': FieldValue.arrayUnion([trimmed]),
    });
  }
}