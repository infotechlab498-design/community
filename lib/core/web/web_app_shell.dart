import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../responsive/layout_breakpoints.dart';

/// Root presentation wrapper.
///
/// - Native platforms: unchanged child (existing mobile app).
/// - Web narrow: full-width mobile UI.
/// - Web wide: soft page background; [WebsiteFrame] is owned by [MainShellScreen]
///   so navigation state stays correct. Pushed routes keep a light canvas.
class WebAppShell extends StatelessWidget {
  final Widget child;

  const WebAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= LayoutBreakpoints.websiteChromeMin;
        return ColoredBox(
          color: wide ? AppColors.surfaceLight : AppColors.backgroundWhite,
          child: child,
        );
      },
    );
  }
}
