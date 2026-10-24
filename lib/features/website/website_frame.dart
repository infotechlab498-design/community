import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/responsive/layout_breakpoints.dart';
import '../main_shell/shell_navigation.dart';
import '../privacy/privacy_policy_screen.dart';
import 'website_nav_items.dart';

/// Persistent website chrome (header + footer) for Flutter Web at wide widths.
///
/// Native mobile builds never use this widget.
class WebsiteFrame extends StatelessWidget {
  final Widget child;

  const WebsiteFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WebsiteHeader(),
        Expanded(child: child),
        const WebsiteFooter(),
      ],
    );
  }
}

class WebsiteHeader extends StatelessWidget {
  const WebsiteHeader({super.key});

  void _goTab(BuildContext context, int index) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    ShellNavigation.instance.switchTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ShellNavigation.instance,
      builder: (context, _) {
        final current = ShellNavigation.instance.index;
        final width = LayoutBreakpoints.widthOf(context);
        final compact = width < LayoutBreakpoints.desktopMin;

        return Material(
          color: AppColors.backgroundWhite,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceMuted, width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: LayoutBreakpoints.contentMaxWidth(context) + 48,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 16 : 24,
                      vertical: 12,
                    ),
                    child: compact
                        ? _CompactHeader(
                            currentIndex: current,
                            onTab: (i) => _goTab(context, i),
                          )
                        : _WideHeader(
                            currentIndex: current,
                            onTab: (i) => _goTab(context, i),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WideHeader extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTab;

  const _WideHeader({required this.currentIndex, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => onTab(0),
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            AppAssets.hubLogo,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tab in kWebsitePrimaryTabs)
                _NavChip(
                  label: tab.label,
                  selected: currentIndex == tab.shellIndex,
                  onTap: () => onTab(tab.shellIndex),
                ),
              _MoreMenu(
                selected: currentIndex == 4,
                onOpenMoreTab: () => onTab(4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTab;

  const _CompactHeader({required this.currentIndex, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onTab(0),
            child: Image.asset(
              AppAssets.hubLogo,
              height: 36,
              alignment: Alignment.centerLeft,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ),
        PopupMenuButton<Object>(
          tooltip: 'Menu',
          icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
          onSelected: (value) {
            if (value is int) {
              onTab(value);
              return;
            }
            if (value is WebsiteMoreLink) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: value.builder),
              );
            }
          },
          itemBuilder: (context) => [
            for (final tab in kWebsitePrimaryTabs)
              PopupMenuItem(value: tab.shellIndex, child: Text(tab.label)),
            const PopupMenuDivider(),
            for (final link in kWebsiteMoreLinks)
              PopupMenuItem(value: link, child: Text(link.label)),
          ],
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor:
            selected ? AppColors.primaryPurple : AppColors.textMuted,
        backgroundColor:
            selected ? AppColors.lightPurpleBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final bool selected;
  final VoidCallback onOpenMoreTab;

  const _MoreMenu({
    required this.selected,
    required this.onOpenMoreTab,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<WebsiteMoreLink>(
      tooltip: 'More',
      offset: const Offset(0, 40),
      onOpened: onOpenMoreTab,
      onSelected: (link) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: link.builder),
        );
      },
      itemBuilder: (context) => [
        for (final link in kWebsiteMoreLinks)
          PopupMenuItem(
            value: link,
            child: Row(
              children: [
                FaIcon(link.icon, size: 14, color: AppColors.primaryPurple),
                const SizedBox(width: 12),
                Text(link.label),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _NavChip(
          label: 'More ▾',
          selected: selected,
          onTap: onOpenMoreTab,
        ),
      ),
    );
  }
}

class WebsiteFooter extends StatelessWidget {
  const WebsiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1F1630),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: LayoutBreakpoints.contentMaxWidth(context),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                '© ${DateTime.now().year} ${AppStrings.appName} — ${AppStrings.appTagline}',
                style: const TextStyle(
                  color: Color(0xFFD4CCE0),
                  fontSize: 13,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const PrivacyPolicyScreen(showBackButton: true),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE9D5FF),
                ),
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
