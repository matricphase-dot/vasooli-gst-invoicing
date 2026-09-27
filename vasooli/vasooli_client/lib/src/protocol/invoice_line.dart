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

abstract class InvoiceLine
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  InvoiceLine._({
    required this.description,
    required this.hsnSac,
    required this.taxableValue,
    required this.gstRatePercent,
  });

  factory InvoiceLine({
    required String description,
    required String hsnSac,
    required double taxableValue,
    required double gstRatePercent,
  }) = _InvoiceLineImpl;

  factory InvoiceLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return InvoiceLine(
      description: jsonSerialization['description'] as String,
      hsnSac: jsonSerialization['hsnSac'] as String,
      taxableValue: (jsonSerialization['taxableValue'] as num).toDouble(),
      gstRatePercent: (jsonSerialization['gstRatePercent'] as num).toDouble(),
    );
  }

  String description;

  String hsnSac;

  double taxableValue;

  double gstRatePercent;

  /// Returns a shallow copy of this [InvoiceLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  InvoiceLine copyWith({
    String? description,
    String? hsnSac,
    double? taxableValue,
    double? gstRatePercent,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InvoiceLine',
      'description': description,
      'hsnSac': hsnSac,
      'taxableValue': taxableValue,
      'gstRatePercent': gstRatePercent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InvoiceLine',
      'description': description,
      'hsnSac': hsnSac,
      'taxableValue': taxableValue,
      'gstRatePercent': gstRatePercent,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _InvoiceLineImpl extends InvoiceLine {
  _InvoiceLineImpl({
    required String description,
    required String hsnSac,
    required double taxableValue,
    required double gstRatePercent,
  }) : super._(
         description: description,
         hsnSac: hsnSac,
         taxableValue: taxableValue,
         gstRatePercent: gstRatePercent,
       );

  /// Returns a shallow copy of this [InvoiceLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  InvoiceLine copyWith({
    String? description,
    String? hsnSac,
    double? taxableValue,
    double? gstRatePercent,
  }) {
    return InvoiceLine(
      description: description ?? this.description,
      hsnSac: hsnSac ?? this.hsnSac,
      taxableValue: taxableValue ?? this.taxableValue,
      gstRatePercent: gstRatePercent ?? this.gstRatePercent,
    );
  }
}
