import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Uploads a receipt photo to Cloudinary with an unsigned preset.
///
/// The cloud and preset names come from `--dart-define` at build time,
/// because this repository is public and they are enough to upload into
/// the account. They still ship inside the APK — anyone holding it can
/// read them — so the preset is the place to cap file size and formats.
///
/// There is no offline queue: Cloudinary has no local cache the way
/// Firestore does, so the upload happens while the form is open and a
/// tool can always be saved without a receipt and get one later.
class ReceiptUpload {
  ReceiptUpload._();

  static const _cloud = String.fromEnvironment('CLOUDINARY_CLOUD');
  static const _preset = String.fromEnvironment('CLOUDINARY_PRESET');

  /// False in a build that was made without the upload settings; the
  /// receipt controls then stay hidden instead of failing on use.
  static bool get isConfigured => _cloud.isNotEmpty && _preset.isNotEmpty;

  /// The secure URL of the uploaded image.
  static Future<String> send(XFile file) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.https('api.cloudinary.com', '/v1_1/$_cloud/image/upload'),
          )
          ..fields['upload_preset'] = _preset
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Upload failed (${response.statusCode})',
        request.url,
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['secure_url'] as String?;
    if (url == null) {
      throw http.ClientException('Upload returned no URL', request.url);
    }
    return url;
  }
}
