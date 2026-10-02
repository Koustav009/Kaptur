import 'package:flutter/foundation.dart';

/// Which environment the app talks to.
enum AppFlavor { dev, prod }

/// Central, per-flavor configuration.
///
/// The flavor is chosen by the entrypoint (`main_dev.dart` / `main_prod.dart`)
/// and can also be forced via `--dart-define=FLAVOR=dev|prod`.
///
/// Base URL resolution order:
///   1. `--dart-define=BASE_URL=...` (handy when testing against a LAN backend)
///   2. prod placeholder URL (prod flavor)
///   3. dev: platform-aware — Android emulator uses 10.0.2.2 to reach the host
///      machine, web/desktop run on the host itself so they use localhost.
///
/// NOTE: prod URL is a placeholder until the production backend exists —
/// update [prodBaseUrl] in one place when it does.
class AppConfig {
  AppConfig._();

  static const String _definedFlavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static const String _baseUrlOverride = String.fromEnvironment('BASE_URL');

  static AppFlavor? _override;

  /// Set by the flavor entrypoint before [runApp].
  static void setFlavor(AppFlavor flavor) => _override = flavor;

  static AppFlavor get flavor =>
      _override ?? (_definedFlavor == 'prod' ? AppFlavor.prod : AppFlavor.dev);

  static bool get isDev => flavor == AppFlavor.dev;
  static bool get isProd => !isDev;

  static String get appTitle => isProd ? 'Kaptur' : 'Kaptur (Dev)';

  static const String prodBaseUrl = 'https://api.kaptur.app';

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    if (isProd) return prodBaseUrl;
    return kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
  }

  /// Rewrites host-local TUSd URLs (uploads/downloads) so they are reachable
  /// from the running platform. The backend returns `localhost:1080` URLs,
  /// but an Android emulator must use `10.0.2.2` to reach the host machine —
  /// the same rule [baseUrl] follows in dev. Prod/web URLs pass through.
  static String resolveMediaUrl(String url) {
    if (isProd || kIsWeb) return url;
    return url.replaceFirst(
      RegExp(r'^https?://(localhost|127\.0\.0\.1)(?=[:/]|$)'),
      'http://10.0.2.2',
    );
  }
}
