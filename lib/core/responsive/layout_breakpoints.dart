import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Viewport breakpoints for NeighborHub.
///
/// Website chrome is used only on **Flutter Web** at tablet/desktop widths.
/// Native Android/iOS always keep the existing mobile application UI.
abstract final class LayoutBreakpoints {
  static const double mobileMax = 767;
  static const double tabletMin = 768;
  static const double desktopMin = 1024;
  static const double wideMin = 1440;

  /// Website top navigation + wide layouts (web only).
  static const double websiteChromeMin = 900;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) =>
      widthOf(context) <= mobileMax;

  static bool isTablet(BuildContext context) {
    final w = widthOf(context);
    return w >= tabletMin && w < desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      widthOf(context) >= desktopMin;

  /// True when the browser should show the professional website chrome.
  static bool useWebsiteLayout(BuildContext context) =>
      kIsWeb && widthOf(context) >= websiteChromeMin;

  /// Max width for primary website content columns.
  static double contentMaxWidth(BuildContext context) {
    final w = widthOf(context);
    if (w >= wideMin) return 1200;
    if (w >= desktopMin) return 1080;
    return 920;
  }
}
