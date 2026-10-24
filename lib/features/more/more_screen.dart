import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/header_top_app_bar.dart';
import '../auth/adminLogin.dart';
import '../contacts/contacts_screen.dart';
import '../gym/gym_timing_screen.dart';
import '../help/help_screen.dart';
import '../namaztiming/prayer_times_screen.dart';
import '../privacy/privacy_policy_screen.dart';
import '../updates/official_updates_screen.dart';

class MoreSectionItem {
  final String title;
  final FaIconData icon;
  final Widget destination;

  const MoreSectionItem({
    required this.title,
    required this.icon,
    required this.destination,
  });
}

class MoreScreen extends StatelessWidget {
  final bool showBackButton;
  final bool websiteLayout;

  const MoreScreen({
    super.key,
    this.showBackButton = false,
    this.websiteLayout = false,
  });

  List<MoreSectionItem> get _sections => const [
        MoreSectionItem(
          title: 'Namaz Timing',
          icon: FontAwesomeIcons.moon,
          destination: PrayerTimesScreen(showBackButton: true),
        ),
        MoreSectionItem(
          title: 'Contacts',
          icon: FontAwesomeIcons.addressBook,
          destination: ContactsScreen(showBackButton: true),
        ),
        MoreSectionItem(
          title: 'GYM Timing',
          icon: FontAwesomeIcons.dumbbell,
          destination: GymTimingScreen(showBackButton: true),
        ),
        MoreSectionItem(
          title: 'Official Updates',
          icon: FontAwesomeIcons.bullhorn,
          destination: OfficialUpdatesScreen(showBackButton: true),
        ),
        MoreSectionItem(
          title: 'Help & Support',
          icon: FontAwesomeIcons.circleQuestion,
          destination: HelpScreen(showBackButton: true),
        ),
        MoreSectionItem(
          title: 'Privacy Policy',
          icon: FontAwesomeIcons.shieldHalved,
          destination: PrivacyPolicyScreen(showBackButton: true),
        ),
        MoreSectionItem(
          title: 'Admin Login',
          icon: FontAwesomeIcons.userShield,
          destination: AdminLoginScreen(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final sections = _sections;

    if (websiteLayout) {
      return ColoredBox(
        color: AppColors.surfaceLight,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          children: [
            const Text(
              'More services',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Additional community tools and account access.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth >= 720 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sections.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 2.4,
                  ),
                  itemBuilder: (context, index) {
                    final item = sections[index];
                    return _MoreTile(
                      item: item,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => item.destination),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: buildHeaderTopAppBar(context, showBackButton: showBackButton),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = sections[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => item.destination),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.lightPinkPill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(
                      item.icon,
                      size: 22,
                      color: AppColors.brandMagenta,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFFA0AEC0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final MoreSectionItem item;
  final VoidCallback onTap;

  const _MoreTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceMuted),
          ),
          child: Row(
            children: [
              FaIcon(item.icon, size: 18, color: AppColors.primaryPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
