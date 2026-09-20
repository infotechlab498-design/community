import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../shared/widgets/header_top_app_bar.dart';
import '../contacts/contacts_screen.dart';
import '../gym/gym_timing_screen.dart';
import '../updates/official_updates_screen.dart';
import '../water/water_timing_screen.dart';
import '../water/water_supply_screen.dart';
import '../shuttle/shuttle_service_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          feature,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3436),
          ),
        ),
        content: const Text(
          'This service is currently being upgraded and will be available soon!',
          style: TextStyle(color: Color(0xFF596063), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const HeaderTopAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title Section
            const Text(
              'Community Services',
              style: TextStyle(
                color: Color(0xFF2C3436),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Quick access to daily info',
              style: TextStyle(
                color: Color(0xFF596063),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Water Plant Timing (filtration plant)
            InkWell(
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(1);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const WaterTimingScreen(showBackButton: true),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(17),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFF7C3AED), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A2C3436),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          AppAssets.overlay,
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15)
                                .withAlpha(117), // 0xFACC1575
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Text(
                            'Open',
                            style: TextStyle(
                              color: Color(0xFF876E09),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Water Plant Timing',
                      style: TextStyle(
                        color: Color(0xFF2C3436),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Next distribution cycle starts at\n06:00 AM tomorrow.',
                      style: TextStyle(
                        color: Color(0xFF747C7E),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Water Supply (block calendar)
            InkWell(
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(2);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const WaterSupplyScreen(showBackButton: true),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0878C9), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDF4FF),
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: Color(0xFF0878C9),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Supply',
                            style: TextStyle(
                              color: Color(0xFF2C3436),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Check when water supply is available\nin your block.',
                            style: TextStyle(
                              color: Color(0xFF596063),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Shuttle Service
            InkWell(
              onTap: () {
                if (onNavigateToTab != null) {
                  onNavigateToTab!(3);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const ShuttleServiceScreen(showBackButton: true),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x3B216C8C), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        AppAssets.shuttle,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shuttle Service',
                            style: TextStyle(
                              color: Color(0xFF2C3436),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Live tracking of the inter-sector\ncommunity van.',
                            style: TextStyle(
                              color: Color(0xFF596063),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Emergency
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContactsScreen(showBackButton: true),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x3B216C8C), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        AppAssets.emergency,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency',
                            style: TextStyle(
                              color: Color(0xFF2C3436),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Direct lines for medical, security, and fire services.',
                            style: TextStyle(
                              color: Color(0xFF596063),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card 4: Latest Announcement Banner
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const OfficialUpdatesScreen(showBackButton: true),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 31,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x337C3AED),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                AppAssets.rightArrow,
                                width: 28,
                                height: 28,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Latest Announcement',
                                style: TextStyle(
                                  color: Color(0xFFF2EBFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Weekend\nCommunity Fair',
                            style: TextStyle(
                              color: Color(0xFFF8F8FF),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Join us this Saturday for th…',
                            style: TextStyle(
                              color: Color(0xFFF8F8FF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppAssets.rightArrow,
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Horizontal Quick Service Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickPill(
                    context,
                    title: 'Electricity',
                    onTap: () => _showComingSoonDialog(
                      context,
                      'Electricity Management',
                    ),
                  ),
                  _buildQuickPill(
                    context,
                    title: 'GYM Timing',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const GymTimingScreen(showBackButton: true),
                        ),
                      );
                    },
                  ),
                  _buildQuickPill(
                    context,
                    title: 'Waste Mgmt',
                    onTap: () =>
                        _showComingSoonDialog(context, 'Waste Management'),
                  ),
                  _buildQuickPill(
                    context,
                    title: 'Official Updates',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const OfficialUpdatesScreen(showBackButton: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Card 5: Verified Community Trust Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF472B6).withAlpha(45), // #F472B64D
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x26ACB3B6), width: 1),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      AppAssets.community,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA72368),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Verified Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Trusted by 2,400+\nResidents',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFA72368),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Providing essential services and up-to-the-minute infrastructure information since 2018.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF466370),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF7D1E6),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0xFFA72368).withAlpha(40),
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFA72368),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
