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
import 'package:vasooli_client/src/protocol/protocol.dart' as _ilqwwu4d;
import 'invoice_line.dart' as _inr7qgak;
import 'invoice_status.dart' as _iat4j3t6;

abstract class Invoice
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Invoice._({
    this.id,
    required this.invoiceNumber,
    required this.financialYear,
    required this.issueDate,
    required this.clientName,
    this.clientGstin,
    required this.supplierStateCode,
    required this.placeOfSupplyStateCode,
    required this.status,
    required this.lines,
    required this.totalTaxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.grandTotal,
  });

  factory Invoice({
    int? id,
    required String invoiceNumber,
    required String financialYear,
    required DateTime issueDate,
    required String clientName,
    String? clientGstin,
    required int supplierStateCode,
    required int placeOfSupplyStateCode,
    required _iat4j3t6.InvoiceStatus status,
    required List<_inr7qgak.InvoiceLine> lines,
    required double totalTaxable,
    required double cgst,
    required double sgst,
    required double igst,
    required double grandTotal,
  }) = _InvoiceImpl;

  factory Invoice.fromJson(Map<String, dynamic> jsonSerialization) {
    return Invoice(
      id: jsonSerialization['id'] as int?,
      invoiceNumber: jsonSerialization['invoiceNumber'] as String,
      financialYear: jsonSerialization['financialYear'] as String,
      issueDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['issueDate'],
      ),
      clientName: jsonSerialization['clientName'] as String,
      clientGstin: jsonSerialization['clientGstin'] as String?,
      supplierStateCode: jsonSerialization['supplierStateCode'] as int,
      placeOfSupplyStateCode:
          jsonSerialization['placeOfSupplyStateCode'] as int,
      status: _iat4j3t6.InvoiceStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      lines: _ilqwwu4d.Protocol().deserialize<List<_inr7qgak.InvoiceLine>>(
        jsonSerialization['lines'],
      ),
      totalTaxable: (jsonSerialization['totalTaxable'] as num).toDouble(),
      cgst: (jsonSerialization['cgst'] as num).toDouble(),
      sgst: (jsonSerialization['sgst'] as num).toDouble(),
      igst: (jsonSerialization['igst'] as num).toDouble(),
      grandTotal: (jsonSerialization['grandTotal'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String invoiceNumber;

  String financialYear;

  DateTime issueDate;

  String clientName;

  String? clientGstin;

  int supplierStateCode;

  int placeOfSupplyStateCode;

  _iat4j3t6.InvoiceStatus status;

  List<_inr7qgak.InvoiceLine> lines;

  double totalTaxable;

  double cgst;

  double sgst;

  double igst;

  double grandTotal;

  /// Returns a shallow copy of this [Invoice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    String? financialYear,
    DateTime? issueDate,
    String? clientName,
    String? clientGstin,
    int? supplierStateCode,
    int? placeOfSupplyStateCode,
    _iat4j3t6.InvoiceStatus? status,
    List<_inr7qgak.InvoiceLine>? lines,
    double? totalTaxable,
    double? cgst,
    double? sgst,
    double? igst,
    double? grandTotal,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Invoice',
      if (id != null) 'id': id,
      'invoiceNumber': invoiceNumber,
      'financialYear': financialYear,
      'issueDate': issueDate.toJson(),
      'clientName': clientName,
      if (clientGstin != null) 'clientGstin': clientGstin,
      'supplierStateCode': supplierStateCode,
      'placeOfSupplyStateCode': placeOfSupplyStateCode,
      'status': status.toJson(),
      'lines': lines.toJson(valueToJson: (v) => v.toJson()),
      'totalTaxable': totalTaxable,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'grandTotal': grandTotal,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Invoice',
      if (id != null) 'id': id,
      'invoiceNumber': invoiceNumber,
      'financialYear': financialYear,
      'issueDate': issueDate.toJson(),
      'clientName': clientName,
      if (clientGstin != null) 'clientGstin': clientGstin,
      'supplierStateCode': supplierStateCode,
      'placeOfSupplyStateCode': placeOfSupplyStateCode,
      'status': status.toJson(),
      'lines': lines.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalTaxable': totalTaxable,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'grandTotal': grandTotal,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InvoiceImpl extends Invoice {
  _InvoiceImpl({
    int? id,
    required String invoiceNumber,
    required String financialYear,
    required DateTime issueDate,
    required String clientName,
    String? clientGstin,
    required int supplierStateCode,
    required int placeOfSupplyStateCode,
    required _iat4j3t6.InvoiceStatus status,
    required List<_inr7qgak.InvoiceLine> lines,
    required double totalTaxable,
    required double cgst,
    required double sgst,
    required double igst,
    required double grandTotal,
  }) : super._(
         id: id,
         invoiceNumber: invoiceNumber,
         financialYear: financialYear,
         issueDate: issueDate,
         clientName: clientName,
         clientGstin: clientGstin,
         supplierStateCode: supplierStateCode,
         placeOfSupplyStateCode: placeOfSupplyStateCode,
         status: status,
         lines: lines,
         totalTaxable: totalTaxable,
         cgst: cgst,
         sgst: sgst,
         igst: igst,
         grandTotal: grandTotal,
       );

  /// Returns a shallow copy of this [Invoice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Invoice copyWith({
    Object? id = _Undefined,
    String? invoiceNumber,
    String? financialYear,
    DateTime? issueDate,
    String? clientName,
    Object? clientGstin = _Undefined,
    int? supplierStateCode,
    int? placeOfSupplyStateCode,
    _iat4j3t6.InvoiceStatus? status,
    List<_inr7qgak.InvoiceLine>? lines,
    double? totalTaxable,
    double? cgst,
    double? sgst,
    double? igst,
    double? grandTotal,
  }) {
    return Invoice(
      id: id is int? ? id : this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      financialYear: financialYear ?? this.financialYear,
      issueDate: issueDate ?? this.issueDate,
      clientName: clientName ?? this.clientName,
      clientGstin: clientGstin is String? ? clientGstin : this.clientGstin,
      supplierStateCode: supplierStateCode ?? this.supplierStateCode,
      placeOfSupplyStateCode:
          placeOfSupplyStateCode ?? this.placeOfSupplyStateCode,
      status: status ?? this.status,
      lines: lines ?? this.lines.map((e0) => e0.copyWith()).toList(),
      totalTaxable: totalTaxable ?? this.totalTaxable,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      igst: igst ?? this.igst,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }
}
