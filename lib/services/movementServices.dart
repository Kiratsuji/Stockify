import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movementModel.dart';

class MovementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getCompanyId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _db.collection('users').doc(user.uid).get();
    return userDoc.data()?['companyId'] as String?;
  }

  Future<CollectionReference?> _getMovementsRef() async {
    final companyId = await _getCompanyId();
    if (companyId == null) return null;
    return _db.collection('companies').doc(companyId).collection('movements');
  }

  Future<void> addMovement(Movement movement) async {
    final ref = await _getMovementsRef();
    if (ref == null) throw Exception('Empresa não encontrada.');
    await ref.add(movement.toMap());
  }

  Stream<List<Movement>> getRecentMovementsStream() async* {
    final ref = await _getMovementsRef();
    if (ref == null) {
      yield [];
      return;
    }

    yield* ref
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<Movement>> getAllMovementsStream() async* {
    final ref = await _getMovementsRef();
    if (ref == null) {
      yield [];
      return;
    }

    yield* ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}