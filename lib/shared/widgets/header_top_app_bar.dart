import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

class HeaderTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const HeaderTopAppBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66,
        color: AppColors.backgroundWhite,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textDark),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
              ),
            if (showBackButton) const SizedBox(width: 12),
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
