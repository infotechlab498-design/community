import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/layout_breakpoints.dart';

/// Context-aware app bar for Scaffold slots (correct preferred height on website).
PreferredSizeWidget? buildHeaderTopAppBar(
  BuildContext context, {
  bool showBackButton = false,
  VoidCallback? onBackPressed,
}) {
  final website = LayoutBreakpoints.useWebsiteLayout(context);
  if (website && !showBackButton) {
    return const PreferredSize(
      preferredSize: Size.zero,
      child: SizedBox.shrink(),
    );
  }
  return HeaderTopAppBar(
    showBackButton: showBackButton,
    onBackPressed: onBackPressed,
    websiteStyle: website,
  );
}

class HeaderTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool websiteStyle;

  const HeaderTopAppBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.websiteStyle = false,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(websiteStyle && showBackButton ? 56 : 66);

  @override
  Widget build(BuildContext context) {
    if (websiteStyle && showBackButton) {
      return SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          color: AppColors.backgroundWhite,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed:
                onBackPressed ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text('Back'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textDark),
          ),
        ),
      );
    }

    // Existing mobile app bar — preserved.
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66,
        color: AppColors.backgroundWhite,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onBackPressed ??
                      () => Navigator.of(context).maybePop(),
                ),
              ),
            Image.asset(
              AppAssets.hubLogo,
              height: 44,
              width: 232,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Text(
                'NeighborHub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
