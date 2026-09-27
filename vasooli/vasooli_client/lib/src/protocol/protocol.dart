/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:vasooli_client/src/protocol/invoice.dart' as _irxy21c4;
import 'package:vasooli_client/src/protocol/invoice_line.dart' as _i9kgg74g;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'invalid_gstin_exception.dart' as _izt6mvhj;
import 'invoice.dart' as _ifja8moh;
import 'invoice_line.dart' as _inr7qgak;
import 'invoice_status.dart' as _iat4j3t6;
import 'monthly_summary.dart' as _iu6nkcru;
import 'payment.dart' as _ikmm2vup;
import 'payment_method.dart' as _imotz5ce;
import 'reminder_scan.dart' as _i8razsu4;
export 'greetings/greeting.dart';
export 'invalid_gstin_exception.dart';
export 'invoice.dart';
export 'invoice_line.dart';
export 'invoice_status.dart';
export 'monthly_summary.dart';
export 'payment.dart';
export 'payment_method.dart';
export 'reminder_scan.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _izt6mvhj.InvalidGstinException) {
      return _izt6mvhj.InvalidGstinException.fromJson(data) as T;
    }
    if (t == _ifja8moh.Invoice) {
      return _ifja8moh.Invoice.fromJson(data) as T;
    }
    if (t == _inr7qgak.InvoiceLine) {
      return _inr7qgak.InvoiceLine.fromJson(data) as T;
    }
    if (t == _iat4j3t6.InvoiceStatus) {
      return _iat4j3t6.InvoiceStatus.fromJson(data) as T;
    }
    if (t == _iu6nkcru.MonthlySummary) {
      return _iu6nkcru.MonthlySummary.fromJson(data) as T;
    }
    if (t == _ikmm2vup.Payment) {
      return _ikmm2vup.Payment.fromJson(data) as T;
    }
    if (t == _imotz5ce.PaymentMethod) {
      return _imotz5ce.PaymentMethod.fromJson(data) as T;
    }
    if (t == _i8razsu4.ReminderScan) {
      return _i8razsu4.ReminderScan.fromJson(data) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izt6mvhj.InvalidGstinException?>()) {
      return (data != null
              ? _izt6mvhj.InvalidGstinException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ifja8moh.Invoice?>()) {
      return (data != null ? _ifja8moh.Invoice.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_inr7qgak.InvoiceLine?>()) {
      return (data != null ? _inr7qgak.InvoiceLine.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iat4j3t6.InvoiceStatus?>()) {
      return (data != null ? _iat4j3t6.InvoiceStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iu6nkcru.MonthlySummary?>()) {
      return (data != null ? _iu6nkcru.MonthlySummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikmm2vup.Payment?>()) {
      return (data != null ? _ikmm2vup.Payment.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_imotz5ce.PaymentMethod?>()) {
      return (data != null ? _imotz5ce.PaymentMethod.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8razsu4.ReminderScan?>()) {
      return (data != null ? _i8razsu4.ReminderScan.fromJson(data) : null) as T;
    }
    if (t == List<_inr7qgak.InvoiceLine>) {
      return (data as List)
              .map((e) => deserialize<_inr7qgak.InvoiceLine>(e))
              .toList()
          as T;
    }
    if (t == List<_i9kgg74g.InvoiceLine>) {
      return (data as List)
              .map((e) => deserialize<_i9kgg74g.InvoiceLine>(e))
              .toList()
          as T;
    }
    if (t == List<_irxy21c4.Invoice>) {
      return (data as List)
              .map((e) => deserialize<_irxy21c4.Invoice>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _izw8z7ou.Greeting => 'Greeting',
      _izt6mvhj.InvalidGstinException => 'InvalidGstinException',
      _ifja8moh.Invoice => 'Invoice',
      _inr7qgak.InvoiceLine => 'InvoiceLine',
      _iat4j3t6.InvoiceStatus => 'InvoiceStatus',
      _iu6nkcru.MonthlySummary => 'MonthlySummary',
      _ikmm2vup.Payment => 'Payment',
      _imotz5ce.PaymentMethod => 'PaymentMethod',
      _i8razsu4.ReminderScan => 'ReminderScan',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('vasooli.', '');
    }

    switch (data) {
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _izt6mvhj.InvalidGstinException():
        return 'InvalidGstinException';
      case _ifja8moh.Invoice():
        return 'Invoice';
      case _inr7qgak.InvoiceLine():
        return 'InvoiceLine';
      case _iat4j3t6.InvoiceStatus():
        return 'InvoiceStatus';
      case _iu6nkcru.MonthlySummary():
        return 'MonthlySummary';
      case _ikmm2vup.Payment():
        return 'Payment';
      case _imotz5ce.PaymentMethod():
        return 'PaymentMethod';
      case _i8razsu4.ReminderScan():
        return 'ReminderScan';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'InvalidGstinException') {
      return deserialize<_izt6mvhj.InvalidGstinException>(data['data']);
    }
    if (dataClassName == 'Invoice') {
      return deserialize<_ifja8moh.Invoice>(data['data']);
    }
    if (dataClassName == 'InvoiceLine') {
      return deserialize<_inr7qgak.InvoiceLine>(data['data']);
    }
    if (dataClassName == 'InvoiceStatus') {
      return deserialize<_iat4j3t6.InvoiceStatus>(data['data']);
    }
    if (dataClassName == 'MonthlySummary') {
      return deserialize<_iu6nkcru.MonthlySummary>(data['data']);
    }
    if (dataClassName == 'Payment') {
      return deserialize<_ikmm2vup.Payment>(data['data']);
    }
    if (dataClassName == 'PaymentMethod') {
      return deserialize<_imotz5ce.PaymentMethod>(data['data']);
    }
    if (dataClassName == 'ReminderScan') {
      return deserialize<_i8razsu4.ReminderScan>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('vasooli', this);
    _iacc.Protocol().registerHostProtocol('vasooli', this);
  }

  @override
  String getModuleName() => 'vasooli';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
