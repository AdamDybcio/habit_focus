import 'package:habit_focus/core/config/flavor.dart';

/// Build-time configuration compiled into the app.
///
/// Values come from `--dart-define-from-file=config/<flavor>.json`. They can be
/// read by anyone who unpacks the app, so they must never hold secrets.
class AppConfig {
  /// Creates a configuration. Prefer [AppConfig.fromEnvironment].
  const new({required this.flavor, required this.apiBaseUrl});

  /// Reads the configuration compiled into this build.
  ///
  /// Throws a [FormatException] when a value is missing or unsafe.
  factory fromEnvironment() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    return AppConfig.parse(flavor: flavor, apiBaseUrl: apiBaseUrl);
  }

  /// Validates raw string values and builds a configuration.
  ///
  /// Throws a [FormatException] when a value is missing or unsafe. Plain HTTP
  /// is accepted only for the [Flavor.dev] flavor.
  factory parse({required String flavor, required String apiBaseUrl}) {
    final parsedFlavor = Flavor.values.asNameMap()[flavor];
    if (parsedFlavor == null) {
      throw FormatException('Unknown FLAVOR "$flavor"');
    }

    final uri = Uri.tryParse(apiBaseUrl);
    const schemes = {'http', 'https'};
    if (uri == null || !schemes.contains(uri.scheme) || uri.host.isEmpty) {
      throw const FormatException('API_BASE_URL is missing or invalid');
    }
    if (parsedFlavor != Flavor.dev && uri.scheme != 'https') {
      throw const FormatException('API_BASE_URL must use https outside dev');
    }

    return AppConfig(flavor: parsedFlavor, apiBaseUrl: uri);
  }

  /// Environment the app was built for.
  final Flavor flavor;

  /// Absolute base URL of the backend API.
  final Uri apiBaseUrl;

  /// Whether this is the production build.
  bool get isProd => flavor == Flavor.prod;

  /// Whether verbose logging is allowed in this build.
  bool get loggingEnabled => !isProd;
}
