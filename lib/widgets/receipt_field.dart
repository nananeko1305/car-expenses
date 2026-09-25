import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../services/receipt_upload.dart';
import '../theme/app_colors.dart';

/// Photograph of the receipt: take one, pick one, or look at the one
/// that is already there.
///
/// The upload happens here and now, so the tool is only ever saved with
/// a link that works. Nothing is lost if it fails — the tool saves
/// without a receipt and one can be added later.
class ReceiptField extends StatefulWidget {
  const ReceiptField({
    super.key,
    required this.url,
    required this.onChanged,
    this.enabled = true,
  });

  final String url;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<ReceiptField> createState() => _ReceiptFieldState();
}

class _ReceiptFieldState extends State<ReceiptField> {
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker().pickImage(
      source: source,
      // Plenty for a receipt, and it keeps the upload quick.
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      widget.onChanged(await ReceiptUpload.send(picked));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorText(t, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choose() async {
    final t = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(t.receiptCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(t.receiptGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pick(source);
  }

  @override
  Widget build(BuildContext context) {
    // A build made without the upload settings hides the whole thing
    // rather than offering a button that cannot work.
    if (!ReceiptUpload.isConfigured) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);
    final has = widget.url.isNotEmpty;

    return Card(
      child: ListTile(
        leading: _busy
            ? const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : has
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.url,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image_rounded),
                ),
              )
            : CircleAvatar(
                backgroundColor: context.colors.soft,
                foregroundColor: context.colors.primary,
                child: const Icon(Icons.receipt_long_rounded, size: 20),
              ),
        title: Text(has ? t.receipt : t.addReceipt),
        subtitle: Text(_busy ? t.receiptUploading : t.receiptHint),
        onTap: _busy || !widget.enabled
            ? null
            : (has ? () => launchUrl(Uri.parse(widget.url)) : _choose),
        trailing: !has || _busy || !widget.enabled
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: t.edit,
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: _choose,
                  ),
                  IconButton(
                    tooltip: t.delete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => widget.onChanged(''),
                  ),
                ],
              ),
      ),
    );
  }
}
