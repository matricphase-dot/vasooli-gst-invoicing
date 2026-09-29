import 'package:serverpod/serverpod.dart';

/// `GET /health` on the web server — the liveness + version check the
/// submission links to. Deliberately tiny and dependency-free: if this
/// returns, the server is up and serving the version it claims.
class HealthRoute extends WidgetRoute {
  final String version;
  final String runMode;

  HealthRoute({this.version = '1.0.0', String? runMode})
      : runMode = runMode ?? 'unknown';

  @override
  Future<WebWidget> build(Session session, Request request) async {
    return JsonWidget(
      object: {
        'status': 'ok',
        'app': 'vasooli',
        'version': version,
        'runMode': runMode,
        'time': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }
}
