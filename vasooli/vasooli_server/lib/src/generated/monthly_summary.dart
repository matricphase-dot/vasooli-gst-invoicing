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
import 'package:serverpod/serverpod.dart' as _is;

abstract class MonthlySummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  MonthlySummary._({
    required this.financialYear,
    required this.month,
    required this.invoiceCount,
    required this.draftCount,
    required this.sentCount,
    required this.paidCount,
    required this.overdueCount,
    required this.totalTaxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.collected,
    required this.outstanding,
  });

  factory MonthlySummary({
    required String financialYear,
    required int month,
    required int invoiceCount,
    required int draftCount,
    required int sentCount,
    required int paidCount,
    required int overdueCount,
    required double totalTaxable,
    required double cgst,
    required double sgst,
    required double igst,
    required double collected,
    required double outstanding,
  }) = _MonthlySummaryImpl;

  factory MonthlySummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return MonthlySummary(
      financialYear: jsonSerialization['financialYear'] as String,
      month: jsonSerialization['month'] as int,
      invoiceCount: jsonSerialization['invoiceCount'] as int,
      draftCount: jsonSerialization['draftCount'] as int,
      sentCount: jsonSerialization['sentCount'] as int,
      paidCount: jsonSerialization['paidCount'] as int,
      overdueCount: jsonSerialization['overdueCount'] as int,
      totalTaxable: (jsonSerialization['totalTaxable'] as num).toDouble(),
      cgst: (jsonSerialization['cgst'] as num).toDouble(),
      sgst: (jsonSerialization['sgst'] as num).toDouble(),
      igst: (jsonSerialization['igst'] as num).toDouble(),
      collected: (jsonSerialization['collected'] as num).toDouble(),
      outstanding: (jsonSerialization['outstanding'] as num).toDouble(),
    );
  }

  String financialYear;

  int month;

  int invoiceCount;

  int draftCount;

  int sentCount;

  int paidCount;

  int overdueCount;

  double totalTaxable;

  double cgst;

  double sgst;

  double igst;

  double collected;

  double outstanding;

  /// Returns a shallow copy of this [MonthlySummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MonthlySummary copyWith({
    String? financialYear,
    int? month,
    int? invoiceCount,
    int? draftCount,
    int? sentCount,
    int? paidCount,
    int? overdueCount,
    double? totalTaxable,
    double? cgst,
    double? sgst,
    double? igst,
    double? collected,
    double? outstanding,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MonthlySummary',
      'financialYear': financialYear,
      'month': month,
      'invoiceCount': invoiceCount,
      'draftCount': draftCount,
      'sentCount': sentCount,
      'paidCount': paidCount,
      'overdueCount': overdueCount,
      'totalTaxable': totalTaxable,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'collected': collected,
      'outstanding': outstanding,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MonthlySummary',
      'financialYear': financialYear,
      'month': month,
      'invoiceCount': invoiceCount,
      'draftCount': draftCount,
      'sentCount': sentCount,
      'paidCount': paidCount,
      'overdueCount': overdueCount,
      'totalTaxable': totalTaxable,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'collected': collected,
      'outstanding': outstanding,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _MonthlySummaryImpl extends MonthlySummary {
  _MonthlySummaryImpl({
    required String financialYear,
    required int month,
    required int invoiceCount,
    required int draftCount,
    required int sentCount,
    required int paidCount,
    required int overdueCount,
    required double totalTaxable,
    required double cgst,
    required double sgst,
    required double igst,
    required double collected,
    required double outstanding,
  }) : super._(
         financialYear: financialYear,
         month: month,
         invoiceCount: invoiceCount,
         draftCount: draftCount,
         sentCount: sentCount,
         paidCount: paidCount,
         overdueCount: overdueCount,
         totalTaxable: totalTaxable,
         cgst: cgst,
         sgst: sgst,
         igst: igst,
         collected: collected,
         outstanding: outstanding,
       );

  /// Returns a shallow copy of this [MonthlySummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MonthlySummary copyWith({
    String? financialYear,
    int? month,
    int? invoiceCount,
    int? draftCount,
    int? sentCount,
    int? paidCount,
    int? overdueCount,
    double? totalTaxable,
    double? cgst,
    double? sgst,
    double? igst,
    double? collected,
    double? outstanding,
  }) {
    return MonthlySummary(
      financialYear: financialYear ?? this.financialYear,
      month: month ?? this.month,
      invoiceCount: invoiceCount ?? this.invoiceCount,
      draftCount: draftCount ?? this.draftCount,
      sentCount: sentCount ?? this.sentCount,
      paidCount: paidCount ?? this.paidCount,
      overdueCount: overdueCount ?? this.overdueCount,
      totalTaxable: totalTaxable ?? this.totalTaxable,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      igst: igst ?? this.igst,
      collected: collected ?? this.collected,
      outstanding: outstanding ?? this.outstanding,
    );
  }
}
