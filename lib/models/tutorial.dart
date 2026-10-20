import 'package:cloud_firestore/cloud_firestore.dart';

/// A car make in the tutorials, stored in `tutorialBrands/{id}`.
///
/// Tutorials are the workshop's shared knowledge, so anyone may rename or
/// delete a make; [ownerId] only records who added it.
class TutorialBrand {
  const TutorialBrand({
    required this.id,
    required this.ownerId,
    required this.name,
  });

  final String id;
  final String ownerId;

  /// e.g. "Volkswagen".
  final String name;

  factory TutorialBrand.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TutorialBrand(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// One model of a make, stored in `tutorialModels/{id}`. Its links and
/// notes point back to it by id.
class TutorialModel {
  const TutorialModel({
    required this.id,
    required this.ownerId,
    required this.brandId,
    required this.name,
  });

  final String id;
  final String ownerId;
  final String brandId;

  /// e.g. "Passat".
  final String name;

  factory TutorialModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TutorialModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      brandId: data['brandId'] as String? ?? '',
      name: data['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'brandId': brandId,
    'name': name,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// [items] by name, ignoring case, so "audi" sits next to "Alfa Romeo".
List<T> sortedByName<T>(Iterable<T> items, String Function(T) nameOf) =>
    items.toList()..sort(
      (a, b) => nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase()),
    );

/// Whether [name] is already among [names], ignoring case and the spaces
/// around it.
bool nameTaken(String name, Iterable<String> names) {
  final wanted = name.trim().toLowerCase();
  return names.any((n) => n.trim().toLowerCase() == wanted);
}
