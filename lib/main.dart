import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/web/web_app_shell.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean URLs for the website build (no-op impact on mobile UX).
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // System bars only apply on mobile platforms.
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(const CommunityHubApp());
}

class CommunityHubApp extends StatelessWidget {
  const CommunityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return WebAppShell(child: content);
      },
      home: const SplashScreen(),
    );
  }
}
