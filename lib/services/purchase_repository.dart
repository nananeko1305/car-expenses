import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tool.dart';
import '../models/wallet_entry.dart';

/// Writes a wallet withdrawal together with the tool it bought.
///
/// Both documents go in one batch, with the entry id minted on the
/// client. `add()` hands back an id only once the server acknowledges the
/// write, which never happens offline — and every form in this app saves
/// without waiting.
class PurchaseRepository {
  PurchaseRepository._();
  static final PurchaseRepository instance = PurchaseRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> savePurchase({required WalletEntry entry, required Tool tool}) {
    final entryRef = _db.collection('walletEntries').doc();
    final batch = _db.batch()
      ..set(entryRef, {
        ...entry.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(_db.collection('tools').doc(), {
        ...tool.toMap(),
        'entryId': entryRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    return batch.commit();
  }

  /// Whether a wallet entry bought a tool. Such an entry cannot be
  /// deleted: the tool would be left pointing at nothing, and tools are
  /// meant to outlive everything.
  Future<bool> hasTool(String entryId) async {
    final snap = await _db
        .collection('tools')
        .where('entryId', isEqualTo: entryId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
