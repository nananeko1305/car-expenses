import 'package:cloud_firestore/cloud_firestore.dart';

enum Currency { rsd, eur }

Currency currencyFromCode(String? code) =>
    code == 'EUR' ? Currency.eur : Currency.rsd;

extension CurrencyCode on Currency {
  String get code => this == Currency.eur ? 'EUR' : 'RSD';
}

/// One car service, stored in `repairs/{id}`. Visible to every user;
/// [ownerId] is who recorded it and [performedBy] is who did the work.
///
/// The amount is kept in minor units (para / cents) as an int, so sums
/// never suffer from floating point rounding.
class Repair {
  const Repair({
    required this.id,
    required this.ownerId,
    required this.performedBy,
    required this.vehicleId,
    required this.date,
    required this.amountMinor,
    required this.currency,
    required this.description,
    this.mileage,
    this.toWallet = true,
  });

  final String id;
  final String ownerId;

  /// The person who carried out the service.
  final String performedBy;

  final String vehicleId;
  final DateTime date;
  final int amountMinor;
  final Currency currency;
  final String description;

  /// Odometer reading in km at the time of the repair.
  final int? mileage;

  /// Whether the amount went into the shared wallet.
  final bool toWallet;

  factory Repair.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final ownerId = data['ownerId'] as String? ?? '';
    return Repair(
      id: doc.id,
      ownerId: ownerId,
      // Services recorded before the field existed were done by their author.
      performedBy: data['performedBy'] as String? ?? ownerId,
      vehicleId: data['vehicleId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amountMinor: (data['amountMinor'] as num?)?.toInt() ?? 0,
      currency: currencyFromCode(data['currency'] as String?),
      description: data['description'] as String? ?? '',
      mileage: (data['mileage'] as num?)?.toInt(),
      toWallet: data['toWallet'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'performedBy': performedBy,
    'vehicleId': vehicleId,
    'date': Timestamp.fromDate(date),
    'amountMinor': amountMinor,
    'currency': currency.code,
    'description': description,
    'mileage': mileage,
    'toWallet': toWallet,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
