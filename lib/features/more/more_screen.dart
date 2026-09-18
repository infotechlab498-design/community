import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/header_top_app_bar.dart';
import '../contacts/contacts_screen.dart';
import '../gym/gym_timing_screen.dart';
import '../updates/official_updates_screen.dart';
import '../help/help_screen.dart';

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

  const MoreScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final List<MoreSectionItem> sections = [
      const MoreSectionItem(
        title: 'Contacts',
        icon: FontAwesomeIcons.addressBook,
        destination: ContactsScreen(showBackButton: true),
      ),
      const MoreSectionItem(
        title: 'GYM Timing',
        icon: FontAwesomeIcons.dumbbell,
        destination: GymTimingScreen(showBackButton: true),
      ),
      const MoreSectionItem(
        title: 'Official Updates',
        icon: FontAwesomeIcons.bullhorn,
        destination: OfficialUpdatesScreen(showBackButton: true),
      ),
      const MoreSectionItem(
        title: 'Help & Support',
        icon: FontAwesomeIcons.circleQuestion,
        destination: HelpScreen(showBackButton: true),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: HeaderTopAppBar(showBackButton: showBackButton),
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
