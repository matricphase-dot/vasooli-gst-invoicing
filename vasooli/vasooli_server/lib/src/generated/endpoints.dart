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
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:vasooli_server/src/generated/future_calls.dart' as _io1h73uc;
import 'package:vasooli_server/src/generated/invoice_line.dart' as _i3lj72fj;
import 'package:vasooli_server/src/generated/payment_method.dart' as _i2zs3gba;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/invoices.dart' as _i2q1q35v;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'invoices': _i2q1q35v.InvoicesEndpoint()
        ..initialize(
          server,
          'invoices',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['invoices'] = _is.EndpointConnector(
      name: 'invoices',
      endpoint: endpoints['invoices']!,
      methodConnectors: {
        'createInvoice': _is.MethodConnector(
          name: 'createInvoice',
          params: {
            'clientName': _is.ParameterDescription(
              name: 'clientName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'clientGstin': _is.ParameterDescription(
              name: 'clientGstin',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'supplierStateCode': _is.ParameterDescription(
              name: 'supplierStateCode',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'placeOfSupplyStateCode': _is.ParameterDescription(
              name: 'placeOfSupplyStateCode',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'financialYear': _is.ParameterDescription(
              name: 'financialYear',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'lines': _is.ParameterDescription(
              name: 'lines',
              type: _is.getType<List<_i3lj72fj.InvoiceLine>>(),
              nullable: false,
            ),
            'dueDate': _is.ParameterDescription(
              name: 'dueDate',
              type: _is.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['invoices'] as _i2q1q35v.InvoicesEndpoint)
                  .createInvoice(
                    session,
                    clientName: params['clientName'],
                    clientGstin: params['clientGstin'],
                    supplierStateCode: params['supplierStateCode'],
                    placeOfSupplyStateCode: params['placeOfSupplyStateCode'],
                    financialYear: params['financialYear'],
                    lines: params['lines'],
                    dueDate: params['dueDate'],
                  ),
        ),
        'listInvoices': _is.MethodConnector(
          name: 'listInvoices',
          params: {
            'financialYear': _is.ParameterDescription(
              name: 'financialYear',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['invoices'] as _i2q1q35v.InvoicesEndpoint)
                  .listInvoices(
                    session,
                    params['financialYear'],
                  ),
        ),
        'recordPayment': _is.MethodConnector(
          name: 'recordPayment',
          params: {
            'invoiceId': _is.ParameterDescription(
              name: 'invoiceId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'amount': _is.ParameterDescription(
              name: 'amount',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'method': _is.ParameterDescription(
              name: 'method',
              type: _is.getType<_i2zs3gba.PaymentMethod>(),
              nullable: false,
            ),
            'upiReference': _is.ParameterDescription(
              name: 'upiReference',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['invoices'] as _i2q1q35v.InvoicesEndpoint)
                  .recordPayment(
                    session,
                    invoiceId: params['invoiceId'],
                    amount: params['amount'],
                    method: params['method'],
                    upiReference: params['upiReference'],
                    note: params['note'],
                  ),
        ),
        'markPaid': _is.MethodConnector(
          name: 'markPaid',
          params: {
            'invoiceId': _is.ParameterDescription(
              name: 'invoiceId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['invoices'] as _i2q1q35v.InvoicesEndpoint)
                  .markPaid(
                    session,
                    params['invoiceId'],
                  ),
        ),
        'scanOverdue': _is.MethodConnector(
          name: 'scanOverdue',
          params: {
            'financialYear': _is.ParameterDescription(
              name: 'financialYear',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['invoices'] as _i2q1q35v.InvoicesEndpoint)
                  .scanOverdue(
                    session,
                    params['financialYear'],
                  ),
        ),
        'monthlySummary': _is.MethodConnector(
          name: 'monthlySummary',
          params: {
            'financialYear': _is.ParameterDescription(
              name: 'financialYear',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'month': _is.ParameterDescription(
              name: 'month',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['invoices'] as _i2q1q35v.InvoicesEndpoint)
                  .monthlySummary(
                    session,
                    params['financialYear'],
                    params['month'],
                  ),
        ),
        'watchInvoices': _is.MethodStreamConnector(
          name: 'watchInvoices',
          params: {},
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['invoices'] as _i2q1q35v.InvoicesEndpoint)
                  .watchInvoices(session),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _io1h73uc.FutureCalls();
  }
}
