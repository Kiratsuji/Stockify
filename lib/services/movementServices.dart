import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movementModel.dart';

class MovementService {
  final CollectionReference _movementsRef =
  FirebaseFirestore.instance.collection('movements');

  // Adiciona uma nova movimentação
  Future<void> addMovement(Movement movement) async {
    await _movementsRef.add(movement.toMap());
  }

  // Stream que traz as 5 movimentações mais recentes
  Stream<List<Movement>> getRecentMovementsStream() {
    return _movementsRef
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream que traz TODAS as movimentações ordenadas por data
  Stream<List<Movement>> getAllMovementsStream() {
    return _movementsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}