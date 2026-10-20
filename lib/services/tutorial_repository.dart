import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tutorial.dart';
import '../models/tutorial_entry.dart';

/// CRUD for the tutorials: makes, their models, and each model's links
/// and notes. Shared knowledge, so the rules let anyone active change or
/// delete any of it.
///
/// Nothing here is ordered by Firestore: the app sorts, which keeps every
/// query on a single field and needs no composite index.
class TutorialRepository {
  TutorialRepository._();
  static final TutorialRepository instance = TutorialRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _brands =>
      _db.collection('tutorialBrands');
  CollectionReference<Map<String, dynamic>> get _models =>
      _db.collection('tutorialModels');
  CollectionReference<Map<String, dynamic>> get _links =>
      _db.collection('tutorialLinks');
  CollectionReference<Map<String, dynamic>> get _notes =>
      _db.collection('tutorialNotes');

  Stream<List<TutorialBrand>> watchBrands() => _brands.snapshots().map(
    (snap) => snap.docs.map(TutorialBrand.fromDoc).toList(),
  );

  Stream<List<TutorialModel>> watchModels() => _models.snapshots().map(
    (snap) => snap.docs.map(TutorialModel.fromDoc).toList(),
  );

  Stream<List<TutorialLink>> watchLinks() => _links.snapshots().map(
    (snap) => snap.docs.map(TutorialLink.fromDoc).toList(),
  );

  Stream<List<TutorialNote>> watchNotes() => _notes.snapshots().map(
    (snap) => snap.docs.map(TutorialNote.fromDoc).toList(),
  );

  Future<void> saveBrand(TutorialBrand brand) =>
      _save(_brands, brand.id, brand.toMap());

  /// The caller makes sure the make has no models left.
  Future<void> deleteBrand(String id) => _brands.doc(id).delete();

  /// Renames a model; a new one goes through [createModel].
  Future<void> saveModel(TutorialModel model) =>
      _models.doc(model.id).update(model.toMap());

  /// A new model together with its first links, in one write.
  Future<void> createModel(TutorialModel model, List<TutorialLink> links) {
    final batch = _db.batch();
    final ref = _models.doc();
    batch.set(ref, {
      ...model.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    // One server timestamp would give every link the same time, and lose
    // the order they were typed in; a millisecond apart keeps it.
    final now = DateTime.now();
    for (var i = 0; i < links.length; i++) {
      batch.set(_links.doc(), {
        ...links[i].toMap(),
        'modelId': ref.id,
        'createdAt': Timestamp.fromDate(now.add(Duration(milliseconds: i))),
      });
    }
    return batch.commit();
  }

  /// A model and everything hanging off it, in one write.
  Future<void> deleteModel(
    String id, {
    required Iterable<String> linkIds,
    required Iterable<String> noteIds,
  }) {
    final batch = _db.batch()..delete(_models.doc(id));
    for (final l in linkIds) {
      batch.delete(_links.doc(l));
    }
    for (final n in noteIds) {
      batch.delete(_notes.doc(n));
    }
    return batch.commit();
  }

  Future<void> saveLink(TutorialLink link) =>
      _save(_links, link.id, link.toMap());

  Future<void> deleteLink(String id) => _links.doc(id).delete();

  Future<void> saveNote(TutorialNote note) =>
      _save(_notes, note.id, note.toMap());

  Future<void> deleteNote(String id) => _notes.doc(id).delete();

  Future<void> _save(
    CollectionReference<Map<String, dynamic>> collection,
    String id,
    Map<String, dynamic> data,
  ) {
    if (id.isEmpty) {
      return collection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return collection.doc(id).update(data);
  }
}
