import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wallet_entry.dart';

/// CRUD for manual wallet deposits and withdrawals, shared by everyone.
class WalletRepository {
  WalletRepository._();
  static final WalletRepository instance = WalletRepository._();

  final CollectionReference<Map<String, dynamic>> _entries = FirebaseFirestore
      .instance
      .collection('walletEntries');

  Stream<List<WalletEntry>> watchAll() => _entries
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(WalletEntry.fromDoc).toList());

  Future<void> save(WalletEntry entry) {
    if (entry.id.isEmpty) {
      return _entries.add({
        ...entry.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return _entries.doc(entry.id).update(entry.toMap());
  }

  Future<void> delete(String id) => _entries.doc(id).delete();
}
