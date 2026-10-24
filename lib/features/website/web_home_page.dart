import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:community/core/constants/app_colors.dart';
import 'package:community/core/constants/app_strings.dart';
import 'package:community/core/responsive/layout_breakpoints.dart';
import 'package:community/features/contacts/contacts_screen.dart';
import 'package:community/features/gym/gym_timing_screen.dart';
import 'package:community/features/namaztiming/prayer_times_screen.dart';
import 'package:community/features/shuttle/shuttle_service_screen.dart';
import 'package:community/features/updates/official_updates_screen.dart';
import 'package:community/features/water/water_supply_screen.dart';
import 'package:community/features/water/water_timing_screen.dart';

class _ServiceTile {
  final String title;
  final String subtitle;
  final FaIconData icon;
  final Color accent;
  final VoidCallback onOpen;

  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onOpen,
  });
}

/// Desktop/tablet website landing — multi-column service directory.
class WebHomePage extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;

  const WebHomePage({super.key, this.onNavigateToTab});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <_ServiceTile>[
      _ServiceTile(
        title: 'Water Plant Timing',
        subtitle: 'Weekly filtration plant schedule and status',
        icon: FontAwesomeIcons.industry,
        accent: AppColors.primaryPurple,
        onOpen: () => onNavigateToTab?.call(1),
      ),
      _ServiceTile(
        title: 'Ground Water Supply',
        subtitle: 'Block-wise monthly supply calendar',
        icon: FontAwesomeIcons.droplet,
        accent: const Color(0xFF0EA5E9),
        onOpen: () => onNavigateToTab?.call(2),
      ),
      _ServiceTile(
        title: 'Shuttle Service',
        subtitle: 'Route departures and next bus times',
        icon: FontAwesomeIcons.bus,
        accent: const Color(0xFF059669),
        onOpen: () => onNavigateToTab?.call(3),
      ),
      _ServiceTile(
        title: 'Namaz Timing',
        subtitle: 'Daily prayer schedule for the community',
        icon: FontAwesomeIcons.moon,
        accent: const Color(0xFF4F46E5),
        onOpen: () => _open(
          context,
          const PrayerTimesScreen(showBackButton: true),
        ),
      ),
      _ServiceTile(
        title: 'Emergency Contacts',
        subtitle: 'Fire, medical, security, and service numbers',
        icon: FontAwesomeIcons.addressBook,
        accent: AppColors.emergencyRed,
        onOpen: () =>
            _open(context, const ContactsScreen(showBackButton: true)),
      ),
      _ServiceTile(
        title: 'Gym Timing',
        subtitle: 'Male and female session windows',
        icon: FontAwesomeIcons.dumbbell,
        accent: AppColors.gymPurple,
        onOpen: () =>
            _open(context, const GymTimingScreen(showBackButton: true)),
      ),
      _ServiceTile(
        title: 'Official Updates',
        subtitle: 'Notices from community administration',
        icon: FontAwesomeIcons.bullhorn,
        accent: AppColors.noticeGoldText,
        onOpen: () => _open(
          context,
          const OfficialUpdatesScreen(showBackButton: true),
        ),
      ),
      _ServiceTile(
        title: 'Water Timing Detail',
        subtitle: 'Open the full timing screen in this tab',
        icon: FontAwesomeIcons.clock,
        accent: AppColors.brandMagenta,
        onOpen: () => _open(
          context,
          const WaterTimingScreen(showBackButton: true),
        ),
      ),
      _ServiceTile(
        title: 'Supply Calendar',
        subtitle: 'Browse published ground-water months',
        icon: FontAwesomeIcons.calendarDays,
        accent: AppColors.waterDarkGreen,
        onOpen: () => _open(
          context,
          const WaterSupplyScreen(showBackButton: true),
        ),
      ),
      _ServiceTile(
        title: 'Shuttle Routes',
        subtitle: 'Full shuttle board with live next departure',
        icon: FontAwesomeIcons.route,
        accent: const Color(0xFF0891B2),
        onOpen: () => _open(
          context,
          const ShuttleServiceScreen(showBackButton: true),
        ),
      ),
    ];

    final maxW = LayoutBreakpoints.contentMaxWidth(context);
    final width = LayoutBreakpoints.widthOf(context);
    final crossAxisCount = width >= LayoutBreakpoints.wideMin
        ? 3
        : width >= LayoutBreakpoints.desktopMin
            ? 3
            : 2;

    return ColoredBox(
      color: AppColors.surfaceLight,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroBanner(maxWidth: maxW),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              width >= 1024 ? 24 : 16,
              8,
              width >= 1024 ? 24 : 16,
              40,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Community services',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Live schedules and contacts powered by the NeighborHub API.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tiles.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: width >= 1024 ? 1.55 : 1.25,
                        ),
                        itemBuilder: (context, index) {
                          final tile = tiles[index];
                          return _ServiceCard(tile: tile);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final double maxWidth;

  const _HeroBanner({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFA72368)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: 10),
              Text(
                AppStrings.appTagline,
                style: TextStyle(
                  color: Color(0xFFE9D5FF),
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Water · Shuttle · Prayer · Gym · Emergency contacts',
                style: TextStyle(
                  color: Color(0xFFF5F3FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final _ServiceTile tile;

  const _ServiceCard({required this.tile});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hover ? tile.accent.withValues(alpha: 0.45) : AppColors.surfaceMuted,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.08 : 0.04),
              blurRadius: _hover ? 22 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: tile.onOpen,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tile.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(tile.icon, color: tile.accent, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    tile.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tile.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
