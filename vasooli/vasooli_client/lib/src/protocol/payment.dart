/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'payment_method.dart' as _imotz5ce;

abstract class Payment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Payment._({
    this.id,
    required this.invoiceId,
    required this.amount,
    required this.method,
    this.upiReference,
    required this.paidAt,
    this.note,
  });

  factory Payment({
    int? id,
    required int invoiceId,
    required double amount,
    required _imotz5ce.PaymentMethod method,
    String? upiReference,
    required DateTime paidAt,
    String? note,
  }) = _PaymentImpl;

  factory Payment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Payment(
      id: jsonSerialization['id'] as int?,
      invoiceId: jsonSerialization['invoiceId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      method: _imotz5ce.PaymentMethod.fromJson(
        (jsonSerialization['method'] as String),
      ),
      upiReference: jsonSerialization['upiReference'] as String?,
      paidAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['paidAt']),
      note: jsonSerialization['note'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int invoiceId;

  double amount;

  _imotz5ce.PaymentMethod method;

  String? upiReference;

  DateTime paidAt;

  String? note;

  /// Returns a shallow copy of this [Payment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Payment copyWith({
    int? id,
    int? invoiceId,
    double? amount,
    _imotz5ce.PaymentMethod? method,
    String? upiReference,
    DateTime? paidAt,
    String? note,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Payment',
      if (id != null) 'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'method': method.toJson(),
      if (upiReference != null) 'upiReference': upiReference,
      'paidAt': paidAt.toJson(),
      if (note != null) 'note': note,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Payment',
      if (id != null) 'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'method': method.toJson(),
      if (upiReference != null) 'upiReference': upiReference,
      'paidAt': paidAt.toJson(),
      if (note != null) 'note': note,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentImpl extends Payment {
  _PaymentImpl({
    int? id,
    required int invoiceId,
    required double amount,
    required _imotz5ce.PaymentMethod method,
    String? upiReference,
    required DateTime paidAt,
    String? note,
  }) : super._(
         id: id,
         invoiceId: invoiceId,
         amount: amount,
         method: method,
         upiReference: upiReference,
         paidAt: paidAt,
         note: note,
       );

  /// Returns a shallow copy of this [Payment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Payment copyWith({
    Object? id = _Undefined,
    int? invoiceId,
    double? amount,
    _imotz5ce.PaymentMethod? method,
    Object? upiReference = _Undefined,
    DateTime? paidAt,
    Object? note = _Undefined,
  }) {
    return Payment(
      id: id is int? ? id : this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      upiReference: upiReference is String? ? upiReference : this.upiReference,
      paidAt: paidAt ?? this.paidAt,
      note: note is String? ? note : this.note,
    );
  }
}
