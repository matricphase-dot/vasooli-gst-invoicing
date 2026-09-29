import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/cache_busting.dart';
import 'src/generated/protocol.dart';
import 'src/generated/serverpod.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/health_route.dart';

/// When VASOOLI_PREVIEW_SANDBOX is set (the e2b sandbox id), rewrite the
/// public URL of every server to `https://<port>-<id>.e2b.app`. The browser
/// that loads the Flutter web app is NOT this machine, so the config.json
/// it fetches must point the API at the public proxy host, not localhost.
ServerpodConfig _previewProxyOverride(ServerpodConfig config) {
  final sandbox = Platform.environment['VASOOLI_PREVIEW_SANDBOX'];
  if (sandbox == null || sandbox.isEmpty) return config;
  ServerConfig proxied(ServerConfig s) => ServerConfig(
        port: s.port,
        publicHost: '${s.port}-$sandbox.e2b.app',
        publicPort: 443,
        publicScheme: 'https',
      );
  return config.copyWith(
    apiServer: proxied(config.apiServer),
    insightsServer:
        config.insightsServer == null ? null : proxied(config.insightsServer!),
    webServer: config.webServer == null ? null : proxied(config.webServer!),
  );
}

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args, configOverride: _previewProxyOverride);

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      // The default setup works with Serverpod Cloud without configuration. In
      // development the verification codes are logged to the console, and in
      // staging and production they are sent through the Serverpod Cloud email
      // service. If you want to use a custom provider for sending emails, use
      // `EmailIdpConfigFromPasswords`.
      ServerpodCloudEmailIdpConfig(
        appDisplayName: 'vasooli',
      ),
    ],
  );

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  // Liveness/version probe for the submission and for Serverpod Cloud checks.
  pod.webServer.addRoute(
    HealthRoute(runMode: pod.runMode),
    '/health',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under /.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addMiddleware(
      FallbackMiddleware(
        fallback: defaultRoute,
        on: (response) => response.statusCode == 404,
      ).call,
      '/',
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/**',
    );
  }

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Start the server.
  await pod.start();

  // ---- Daily overdue scan ---------------------------------------------------
  // A recurring future call, persisted in Postgres (so it survives restarts):
  // every 24h it flips non-paid invoices past their due date to `overdue`
  // and broadcasts each change on the invoices stream every device watches.
  // The fixed identifier lets it be cancelled cleanly and keeps registration
  // explicit; scheduling a duplicate identifier is harmless (the manager
  // stores unique identifiers for runs, not one row per schedule).
  await pod.futureCalls
      .callRecurring(identifier: 'daily-overdue-scan')
      .every(const Duration(hours: 24))
      .reminderCalls
      .overdueScan(ReminderScan());
}
