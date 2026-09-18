import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/shuttle_route_model.dart';
import '../../data/repositories/community_repository.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class ShuttleServiceScreen extends StatefulWidget {
  final bool showBackButton;

  const ShuttleServiceScreen({super.key, this.showBackButton = false});

  @override
  State<ShuttleServiceScreen> createState() => _ShuttleServiceScreenState();
}

class _ShuttleServiceScreenState extends State<ShuttleServiceScreen> {
  String _activeRoute = 'Route A';

  void _showComingSoon(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('Coming Soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ShuttleDeparture> departures =
        CommunityRepository.getShuttleDepartures(_activeRoute);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: HeaderTopAppBar(showBackButton: widget.showBackButton),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shuttle Service Timing',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Reliable community transportation at your fingertips. View real-time schedules and\nroute details below.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Route Toggle Switcher (Capsule)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0x1F898989),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeRoute = 'Route A'),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _activeRoute == 'Route A'
                              ? AppColors.primaryPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: _activeRoute == 'Route A'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'From Lilly A',
                          style: TextStyle(
                            color: _activeRoute == 'Route A'
                                ? Colors.white
                                : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeRoute = 'Route B'),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _activeRoute == 'Route B'
                              ? AppColors.primaryPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: _activeRoute == 'Route B'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'From Main Gate',
                          style: TextStyle(
                            color: _activeRoute == 'Route B'
                                ? Colors.white
                                : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timetable Container (Fixed 380px height matching React Native)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                height: 380,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: departures.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                  ),
                  itemBuilder: (context, index) {
                    final item = departures[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.lightPurpleBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.time,
                              style: const TextStyle(
                                color: AppColors.primaryPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Support & Alert Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _showComingSoon('Commuter Support'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightPinkPill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              AppAssets.needHelp,
                              width: 44,
                              height: 42,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Support available 24/7 for commuters.',
                              style: TextStyle(
                                color: AppColors.brandMagenta,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => _showComingSoon('Alert Subscriptions'),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              AppAssets.alertIcon,
                              width: 44,
                              height: 44,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alert Subscriptions',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Get notified about real-time delays.',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Travel Notice
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightPinkPill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppAssets.travelIcon,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Travel Notice',
                          style: TextStyle(
                            color: AppColors.brandMagenta,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Potential delays may occur during\npeak hours (08:00 - 10:00) due to\nRain.',
                          style: TextStyle(
                            color: AppColors.textBody,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Route Map Preview Card
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 210,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.serviceMapPreview),
                    fit: BoxFit.cover,
                  ),
                ),
                child: InkWell(
                  onTap: () => _showComingSoon('Route Map'),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xCC7C3AED), Color(0x4D7C3AED)],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Image.asset(
                          AppAssets.mapIcon,
                          width: 14,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'View Full Route Map (Coming Soon)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
