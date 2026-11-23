import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/planned_purchase.dart';

/// CRUD for the to-buy list. Shared by everyone: the rules let anyone
/// active change or delete an item, since whoever buys a thing is the one
/// who takes it off the list.
class PlannedPurchaseRepository {
  PlannedPurchaseRepository._();
  static final PlannedPurchaseRepository instance =
      PlannedPurchaseRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _purchases =>
      _db.collection('plannedPurchases');

  /// Every item, in no order: the app sorts them by priority.
  Stream<List<PlannedPurchase>> watchAll() => _purchases.snapshots().map(
    (snap) => snap.docs.map(PlannedPurchase.fromDoc).toList(),
  );

  Future<void> save(PlannedPurchase purchase) {
    if (purchase.id.isEmpty) {
      return _purchases.add({
        ...purchase.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return _purchases.doc(purchase.id).update(purchase.toMap());
  }

  Future<void> delete(String id) => _purchases.doc(id).delete();
}
