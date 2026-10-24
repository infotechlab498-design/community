import 'package:flutter/foundation.dart';

/// Central NeighborHub API host configuration.
///
/// Resolution order:
/// 1. `--dart-define=API_BASE_URL=...` (any build / platform)
/// 2. Production host when [kReleaseMode] is true (Android, iOS, **Web**)
/// 3. Android emulator loopback / localhost for debug & profile only
///
/// Release builds (including Flutter web) never fall back to localhost.
abstract final class ApiConfig {
  /// Deployed Somee host used by Play Store / release / website builds.
  static const String productionBaseUrl = 'https://usama498.bsite.net';

  /// Local API when running on an Android emulator against the host machine.
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5162';

  /// Local API for desktop, iOS simulator, and web debug sessions.
  static const String localDevBaseUrl = 'http://localhost:5162';

  /// Compile-time override from `--dart-define=API_BASE_URL=...`.
  static const String definedBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  /// Resolved base URL for the current build (no trailing slash).
  static String get baseUrl => resolveBaseUrl(
        definedBaseUrl: definedBaseUrl,
        isRelease: kReleaseMode,
        isAndroid: !kIsWeb &&
            defaultTargetPlatform == TargetPlatform.android,
      );

  /// Pure resolver used by [baseUrl] and unit tests.
  static String resolveBaseUrl({
    required String definedBaseUrl,
    required bool isRelease,
    required bool isAndroid,
  }) {
    final override = definedBaseUrl.trim();
    if (override.isNotEmpty) {
      return normalizeBaseUrl(override);
    }
    if (isRelease) {
      return productionBaseUrl;
    }
    if (isAndroid) {
      return androidEmulatorBaseUrl;
    }
    return localDevBaseUrl;
  }

  static String normalizeBaseUrl(String url) {
    var value = url.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }
}
