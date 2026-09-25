import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tool.dart';

/// CRUD for tools, shared by everyone. There is no delete: a tool is
/// archived instead, so the spending that bought it is never at risk.
class ToolRepository {
  ToolRepository._();
  static final ToolRepository instance = ToolRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tools =>
      _db.collection('tools');

  /// Every tool, newest purchase first. Archived ones come along and are
  /// filtered in the UI — filtering here as well would need a composite
  /// index for one small collection.
  Stream<List<Tool>> watchAll() => _tools
      .orderBy('purchaseDate', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Tool.fromDoc).toList());

  Future<void> save(Tool tool) {
    if (tool.id.isEmpty) {
      return _tools.add({
        ...tool.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return _tools.doc(tool.id).update(tool.toMap());
  }

  /// Archiving is a field write, not a delete, and leaves the rest of the
  /// document — including the reminder bookkeeping — untouched.
  Future<void> setArchived(String id, bool archived) => _tools.doc(id).update({
    'archived': archived,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
