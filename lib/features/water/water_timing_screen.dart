import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/phone_launcher.dart';
import '../../data/models/water_schedule_model.dart';
import '../../data/repositories/community_repository.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class WaterTimingScreen extends StatefulWidget {
  final bool showBackButton;

  const WaterTimingScreen({super.key, this.showBackButton = false});

  @override
  State<WaterTimingScreen> createState() => _WaterTimingScreenState();
}

class _WaterTimingScreenState extends State<WaterTimingScreen> {
  List<WaterScheduleItem> _schedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await CommunityRepository.loadWaterSchedule();
      // Sunday-to-last sorting matching React Native: (a.id === 0 ? 7 : a.id) - (b.id === 0 ? 7 : b.id)
      data.sort((a, b) => a.sortKey.compareTo(b.sortKey));
      if (mounted) {
        setState(() {
          _schedule = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int get _todayIndex {
    // Dart: 1=Mon, ..., 6=Sat, 7=Sun.
    // React Native getDay(): 0=Sun, 1=Mon, ..., 6=Sat.
    final now = DateTime.now();
    return now.weekday == 7 ? 0 : now.weekday;
  }

  @override
  Widget build(BuildContext context) {
    // Locate today's schedule
    final todayItem = _schedule.cast<WaterScheduleItem?>().firstWhere(
          (item) => item?.id == _todayIndex,
          orElse: () => null,
        );
    final todayTimeText = todayItem?.time ?? '9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: HeaderTopAppBar(showBackButton: widget.showBackButton),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card: Main Filtration Plant
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.waterPlant),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(top: 80, left: 24, bottom: 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x992C3436), Color(0x002C3436)],
                          ),
                        ),
                        child: const Text(
                          'Main Filtration\nPlant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Today Status Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.waterLightGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x12306952),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.communityIcon,
                          width: 40,
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Open today $todayTimeText',
                                style: const TextStyle(
                                  color: AppColors.waterDarkGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Standard community distribution\nhours',
                                style: TextStyle(
                                  color: AppColors.textBody,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weekly Schedule Header
                  Row(
                    children: [
                      Image.asset(
                        AppAssets.weeklySchedule,
                        width: 18,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Weekly Schedule',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Weekly Schedule Table (Monday through Sunday)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: _schedule.map((item) {
                        final isToday = item.id == _todayIndex;

                        if (isToday) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  item.day,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(60),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: const Text(
                                    'Today',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  item.time,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                item.day,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item.time,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Last Updated Status
                  Row(
                    children: [
                      const Spacer(),
                      Image.asset(
                        AppAssets.lastUpdate,
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Last updated: 2 hours ago',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Support Contact Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support Contact',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => PhoneLauncher.makePhoneCall(
                                context,
                                AppStrings.phoneWaterMaintenance,
                              ),
                              child: Image.asset(
                                AppAssets.phoneIcon,
                                width: 24,
                                height: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Maintenance Team',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                InkWell(
                                  onTap: () => PhoneLauncher.makePhoneCall(
                                    context,
                                    AppStrings.phoneWaterMaintenance,
                                  ),
                                  child: const Text(
                                    AppStrings.phoneWaterMaintenance,
                                    style: TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ISO 22000 Certification Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            AppAssets.certifiedIcon,
                            width: 44,
                            height: 44,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Certified Safe for Potable Use (ISO 22000)',
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
