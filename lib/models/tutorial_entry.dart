import 'package:cloud_firestore/cloud_firestore.dart';

/// A link for working on one model, stored in `tutorialLinks/{id}`.
class TutorialLink {
  const TutorialLink({
    required this.id,
    required this.ownerId,
    required this.modelId,
    required this.title,
    required this.url,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final String modelId;

  /// e.g. "Clutch replacement"; may be empty.
  final String title;

  /// Always an http(s) address; see [normalizeUrl].
  final String url;

  /// Null while the write is still on its way to the server.
  final DateTime? createdAt;

  /// The site, e.g. "youtube.com".
  String get host =>
      (Uri.tryParse(url)?.host ?? '').replaceFirst(RegExp(r'^www\.'), '');

  /// What the list shows: the title, or the address without its scheme.
  String get label =>
      title.isNotEmpty ? title : url.replaceFirst(RegExp(r'^https?://'), '');

  bool get isVideo =>
      host == 'youtu.be' ||
      host == 'youtube.com' ||
      host.endsWith('.youtube.com');

  /// [links] in the order they were added, one still saving last.
  static List<TutorialLink> inOrder(Iterable<TutorialLink> links) =>
      links.toList()
        ..sort((a, b) => _when(a.createdAt).compareTo(_when(b.createdAt)));

  factory TutorialLink.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TutorialLink(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      modelId: data['modelId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      url: data['url'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Leaves out `createdAt`: the repository sets it once, on create.
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'modelId': modelId,
    'title': title,
    'url': url,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// Something worth knowing about one model, stored in `tutorialNotes/{id}`.
class TutorialNote {
  const TutorialNote({
    required this.id,
    required this.ownerId,
    required this.modelId,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final String modelId;
  final String text;

  /// Null while the write is still on its way to the server.
  final DateTime? createdAt;

  /// [notes] newest first, one still saving at the top.
  static List<TutorialNote> newestFirst(Iterable<TutorialNote> notes) =>
      notes.toList()
        ..sort((a, b) => _when(b.createdAt).compareTo(_when(a.createdAt)));

  factory TutorialNote.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return TutorialNote(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      modelId: data['modelId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Leaves out `createdAt`: the repository sets it once, on create.
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'modelId': modelId,
    'text': text,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// A write still on its way has no time yet; it counts as the newest.
DateTime _when(DateTime? d) => d ?? DateTime(9999);

/// The web address someone meant: trimmed, with `https://` added when
/// they typed none ("youtube.com/watch?v=…"). Null for anything that is
/// not an http(s) address with a real host, such as `mailto:` or text
/// with spaces in it.
String? normalizeUrl(String input) {
  final s = input.trim();
  if (s.isEmpty || s.contains(RegExp(r'\s'))) return null;
  // "mailto:" or "javascript:" is a scheme; "site.com:8080" is a port.
  final hasScheme =
      s.contains('://') ||
      RegExp(r'^[a-zA-Z][a-zA-Z0-9+-]*:(?!\d)').hasMatch(s);
  final uri = Uri.tryParse(hasScheme ? s : 'https://$s');
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      !uri.host.contains('.')) {
    return null;
  }
  return uri.toString();
}
