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
import 'package:vasooli_server/src/generated/protocol.dart' as _icxkkny5;
import 'invoice_line.dart' as _inr7qgak;
import 'invoice_status.dart' as _iat4j3t6;

abstract class Invoice
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Invoice._({
    this.id,
    required this.invoiceNumber,
    required this.financialYear,
    required this.issueDate,
    this.dueDate,
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
    DateTime? dueDate,
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
      issueDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['issueDate'],
      ),
      dueDate: jsonSerialization['dueDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      clientName: jsonSerialization['clientName'] as String,
      clientGstin: jsonSerialization['clientGstin'] as String?,
      supplierStateCode: jsonSerialization['supplierStateCode'] as int,
      placeOfSupplyStateCode:
          jsonSerialization['placeOfSupplyStateCode'] as int,
      status: _iat4j3t6.InvoiceStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      lines: _icxkkny5.Protocol().deserialize<List<_inr7qgak.InvoiceLine>>(
        jsonSerialization['lines'],
      ),
      totalTaxable: (jsonSerialization['totalTaxable'] as num).toDouble(),
      cgst: (jsonSerialization['cgst'] as num).toDouble(),
      sgst: (jsonSerialization['sgst'] as num).toDouble(),
      igst: (jsonSerialization['igst'] as num).toDouble(),
      grandTotal: (jsonSerialization['grandTotal'] as num).toDouble(),
    );
  }

  static final t = InvoiceTable();

  static const db = InvoiceRepository._();

  @override
  int? id;

  String invoiceNumber;

  String financialYear;

  DateTime issueDate;

  DateTime? dueDate;

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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Invoice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    String? financialYear,
    DateTime? issueDate,
    DateTime? dueDate,
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
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
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
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
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

  static InvoiceInclude include() {
    return InvoiceInclude._();
  }

  static InvoiceIncludeList includeList({
    _is.WhereExpressionBuilder<InvoiceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InvoiceTable>? orderBy,
    _is.OrderByListBuilder<InvoiceTable>? orderByList,
    InvoiceInclude? include,
  }) {
    return InvoiceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Invoice.t),
      orderByList: orderByList?.call(Invoice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InvoiceImpl extends Invoice {
  _InvoiceImpl({
    int? id,
    required String invoiceNumber,
    required String financialYear,
    required DateTime issueDate,
    DateTime? dueDate,
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
         dueDate: dueDate,
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
  @_is.useResult
  @override
  Invoice copyWith({
    Object? id = _Undefined,
    String? invoiceNumber,
    String? financialYear,
    DateTime? issueDate,
    Object? dueDate = _Undefined,
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
      dueDate: dueDate is DateTime? ? dueDate : this.dueDate,
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

class InvoiceUpdateTable extends _is.UpdateTable<InvoiceTable> {
  InvoiceUpdateTable(super.table);

  _is.ColumnValue<String, String> invoiceNumber(String value) =>
      _is.ColumnValue(
        table.invoiceNumber,
        value,
      );

  _is.ColumnValue<String, String> financialYear(String value) =>
      _is.ColumnValue(
        table.financialYear,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> issueDate(DateTime value) =>
      _is.ColumnValue(
        table.issueDate,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> dueDate(DateTime? value) =>
      _is.ColumnValue(
        table.dueDate,
        value,
      );

  _is.ColumnValue<String, String> clientName(String value) => _is.ColumnValue(
    table.clientName,
    value,
  );

  _is.ColumnValue<String, String> clientGstin(String? value) => _is.ColumnValue(
    table.clientGstin,
    value,
  );

  _is.ColumnValue<int, int> supplierStateCode(int value) => _is.ColumnValue(
    table.supplierStateCode,
    value,
  );

  _is.ColumnValue<int, int> placeOfSupplyStateCode(int value) =>
      _is.ColumnValue(
        table.placeOfSupplyStateCode,
        value,
      );

  _is.ColumnValue<_iat4j3t6.InvoiceStatus, _iat4j3t6.InvoiceStatus> status(
    _iat4j3t6.InvoiceStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<List<_inr7qgak.InvoiceLine>, List<_inr7qgak.InvoiceLine>>
  lines(List<_inr7qgak.InvoiceLine> value) => _is.ColumnValue(
    table.lines,
    value,
  );

  _is.ColumnValue<double, double> totalTaxable(double value) => _is.ColumnValue(
    table.totalTaxable,
    value,
  );

  _is.ColumnValue<double, double> cgst(double value) => _is.ColumnValue(
    table.cgst,
    value,
  );

  _is.ColumnValue<double, double> sgst(double value) => _is.ColumnValue(
    table.sgst,
    value,
  );

  _is.ColumnValue<double, double> igst(double value) => _is.ColumnValue(
    table.igst,
    value,
  );

  _is.ColumnValue<double, double> grandTotal(double value) => _is.ColumnValue(
    table.grandTotal,
    value,
  );
}

class InvoiceTable extends _is.Table<int?> {
  InvoiceTable({super.tableRelation}) : super(tableName: 'invoice') {
    updateTable = InvoiceUpdateTable(this);
    invoiceNumber = _is.ColumnString(
      'invoiceNumber',
      this,
    );
    financialYear = _is.ColumnString(
      'financialYear',
      this,
    );
    issueDate = _is.ColumnDateTime(
      'issueDate',
      this,
    );
    dueDate = _is.ColumnDateTime(
      'dueDate',
      this,
    );
    clientName = _is.ColumnString(
      'clientName',
      this,
    );
    clientGstin = _is.ColumnString(
      'clientGstin',
      this,
    );
    supplierStateCode = _is.ColumnInt(
      'supplierStateCode',
      this,
    );
    placeOfSupplyStateCode = _is.ColumnInt(
      'placeOfSupplyStateCode',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    lines = _is.ColumnSerializable<List<_inr7qgak.InvoiceLine>>(
      'lines',
      this,
    );
    totalTaxable = _is.ColumnDouble(
      'totalTaxable',
      this,
    );
    cgst = _is.ColumnDouble(
      'cgst',
      this,
    );
    sgst = _is.ColumnDouble(
      'sgst',
      this,
    );
    igst = _is.ColumnDouble(
      'igst',
      this,
    );
    grandTotal = _is.ColumnDouble(
      'grandTotal',
      this,
    );
  }

  late final InvoiceUpdateTable updateTable;

  late final _is.ColumnString invoiceNumber;

  late final _is.ColumnString financialYear;

  late final _is.ColumnDateTime issueDate;

  late final _is.ColumnDateTime dueDate;

  late final _is.ColumnString clientName;

  late final _is.ColumnString clientGstin;

  late final _is.ColumnInt supplierStateCode;

  late final _is.ColumnInt placeOfSupplyStateCode;

  late final _is.ColumnEnum<_iat4j3t6.InvoiceStatus> status;

  late final _is.ColumnSerializable<List<_inr7qgak.InvoiceLine>> lines;

  late final _is.ColumnDouble totalTaxable;

  late final _is.ColumnDouble cgst;

  late final _is.ColumnDouble sgst;

  late final _is.ColumnDouble igst;

  late final _is.ColumnDouble grandTotal;

  @override
  List<_is.Column> get columns => [
    id,
    invoiceNumber,
    financialYear,
    issueDate,
    dueDate,
    clientName,
    clientGstin,
    supplierStateCode,
    placeOfSupplyStateCode,
    status,
    lines,
    totalTaxable,
    cgst,
    sgst,
    igst,
    grandTotal,
  ];
}

class InvoiceInclude extends _is.IncludeObject {
  InvoiceInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Invoice.t;
}

class InvoiceIncludeList extends _is.IncludeList {
  InvoiceIncludeList._({
    _is.WhereExpressionBuilder<InvoiceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Invoice.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Invoice.t;
}

class InvoiceRepository {
  const InvoiceRepository._();

  /// Returns a list of [Invoice]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Invoice>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InvoiceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InvoiceTable>? orderBy,
    _is.OrderByListBuilder<InvoiceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Invoice>(
      where: where?.call(Invoice.t),
      orderBy: orderBy?.call(Invoice.t),
      orderByList: orderByList?.call(Invoice.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Invoice] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Invoice?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InvoiceTable>? where,
    int? offset,
    _is.OrderByBuilder<InvoiceTable>? orderBy,
    _is.OrderByListBuilder<InvoiceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Invoice>(
      where: where?.call(Invoice.t),
      orderBy: orderBy?.call(Invoice.t),
      orderByList: orderByList?.call(Invoice.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Invoice] by its [id] or null if no such row exists.
  Future<Invoice?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Invoice>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Invoice]s in the list and returns the inserted rows.
  ///
  /// The returned [Invoice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Invoice>> insert(
    _is.DatabaseSession session,
    List<Invoice> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Invoice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Invoice] and returns the inserted row.
  ///
  /// The returned [Invoice] will have its `id` field set.
  Future<Invoice> insertRow(
    _is.DatabaseSession session,
    Invoice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Invoice>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Invoice]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Invoice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Invoice>> upsert(
    _is.DatabaseSession session,
    List<Invoice> rows, {
    required _is.ColumnSelections<InvoiceTable> conflictColumns,
    _is.ColumnSelections<InvoiceTable>? updateColumns,
    _is.WhereExpressionBuilder<InvoiceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Invoice>(
      rows,
      conflictColumns: conflictColumns(Invoice.t),
      updateColumns: updateColumns?.call(Invoice.t),
      updateWhere: updateWhere?.call(Invoice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Invoice] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Invoice] will have its `id` field set.
  Future<Invoice?> upsertRow(
    _is.DatabaseSession session,
    Invoice row, {
    required _is.ColumnSelections<InvoiceTable> conflictColumns,
    _is.ColumnSelections<InvoiceTable>? updateColumns,
    _is.WhereExpressionBuilder<InvoiceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Invoice>(
      row,
      conflictColumns: conflictColumns(Invoice.t),
      updateColumns: updateColumns?.call(Invoice.t),
      updateWhere: updateWhere?.call(Invoice.t),
      transaction: transaction,
    );
  }

  /// Updates all [Invoice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Invoice>> update(
    _is.DatabaseSession session,
    List<Invoice> rows, {
    _is.ColumnSelections<InvoiceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Invoice>(
      rows,
      columns: columns?.call(Invoice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Invoice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Invoice> updateRow(
    _is.DatabaseSession session,
    Invoice row, {
    _is.ColumnSelections<InvoiceTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Invoice>(
      row,
      columns: columns?.call(Invoice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Invoice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Invoice?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<InvoiceUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Invoice>(
      id,
      columnValues: columnValues(Invoice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Invoice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Invoice>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<InvoiceUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<InvoiceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InvoiceTable>? orderBy,
    _is.OrderByListBuilder<InvoiceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Invoice>(
      columnValues: columnValues(Invoice.t.updateTable),
      where: where(Invoice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Invoice.t),
      orderByList: orderByList?.call(Invoice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Invoice]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Invoice>> delete(
    _is.DatabaseSession session,
    List<Invoice> rows, {
    _is.OrderByBuilder<InvoiceTable>? orderBy,
    _is.OrderByListBuilder<InvoiceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Invoice>(
      rows,
      orderBy: orderBy?.call(Invoice.t),
      orderByList: orderByList?.call(Invoice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Invoice].
  Future<Invoice> deleteRow(
    _is.DatabaseSession session,
    Invoice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Invoice>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Invoice>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InvoiceTable> where,
    _is.OrderByBuilder<InvoiceTable>? orderBy,
    _is.OrderByListBuilder<InvoiceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Invoice>(
      where: where(Invoice.t),
      orderBy: orderBy?.call(Invoice.t),
      orderByList: orderByList?.call(Invoice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InvoiceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Invoice>(
      where: where?.call(Invoice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Invoice] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InvoiceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Invoice>(
      where: where(Invoice.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
