import 'package:flutter/widgets.dart';

import 'repair.dart';
import 'tool.dart';
import 'warranty.dart';

/// The editable state behind the tool fields, shared by the spending
/// form and the tool form so neither has to own the controllers twice.
class ToolDraft {
  ToolDraft({Tool? tool})
    : name = TextEditingController(text: tool?.name ?? ''),
      warranty = TextEditingController(
        text: (tool?.warrantyAmount ?? _defaultYears).toString(),
      ),
      unit = tool?.warrantyUnit ?? WarrantyUnit.years,
      receiptUrl = tool?.receiptUrl ?? '',
      notify = tool?.notify ?? true;

  /// Two years is the legal warranty on most things, so it is the guess
  /// that needs correcting least often.
  static const _defaultYears = 2;

  final TextEditingController name;
  final TextEditingController warranty;
  WarrantyUnit unit;
  String receiptUrl;
  bool notify;

  void dispose() {
    name.dispose();
    warranty.dispose();
  }

  /// Builds the tool to save. [id] and [entryId] are empty for a tool
  /// that is being created.
  Tool build({
    required String ownerId,
    required DateTime purchaseDate,
    String id = '',
    String entryId = '',
    int? amountMinor,
    Currency? currency,
    bool archived = false,
  }) => Tool(
    id: id,
    ownerId: ownerId,
    name: name.text.trim(),
    purchaseDate: purchaseDate,
    warrantyAmount: int.parse(warranty.text.trim()),
    warrantyUnit: unit,
    amountMinor: amountMinor,
    currency: currency,
    entryId: entryId,
    receiptUrl: receiptUrl,
    notify: notify,
    archived: archived,
  );
}
