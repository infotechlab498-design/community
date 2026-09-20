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

  EdgeInsets _pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360 ? 16.0 : width < 400 ? 20.0 : 24.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  @override
  Widget build(BuildContext context) {
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
              padding: _pagePadding(context),
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
                              const Text(
                                'Open today',
                                style: TextStyle(
                                  color: AppColors.waterDarkGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _AdaptiveHoursText(
                                time: todayTimeText,
                                color: AppColors.waterDarkGreen,
                                alignEnd: false,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Standard community distribution hours',
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
                      const Flexible(
                        child: Text(
                          'Weekly Schedule',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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
                        return _ScheduleDayTile(
                          item: item,
                          isToday: item.id == _todayIndex,
                        );
                      }).toList(),
                    ),
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

class _ScheduleDayTile extends StatelessWidget {
  final WaterScheduleItem item;
  final bool isToday;

  const _ScheduleDayTile({
    required this.item,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final stackHours = width < 400;
    final dayColor = isToday ? Colors.white : AppColors.textDark;
    final hoursColor = isToday ? Colors.white : AppColors.textMuted;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: EdgeInsets.symmetric(
        horizontal: width < 360 ? 12 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primaryPurple : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: stackHours
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayLabel(day: item.day, isToday: isToday, color: dayColor),
                const SizedBox(height: 6),
                _AdaptiveHoursText(
                  time: item.time,
                  color: hoursColor,
                  alignEnd: false,
                ),
              ],
            )
          : Row(
              children: [
                _DayLabel(day: item.day, isToday: isToday, color: dayColor),
                const SizedBox(width: 12),
                Expanded(
                  child: _AdaptiveHoursText(
                    time: item.time,
                    color: hoursColor,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String day;
  final bool isToday;
  final Color color;

  const _DayLabel({
    required this.day,
    required this.isToday,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        if (isToday) ...[
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
        ],
      ],
    );
  }
}

class _AdaptiveHoursText extends StatelessWidget {
  final String time;
  final Color color;
  final bool alignEnd;

  const _AdaptiveHoursText({
    required this.time,
    required this.color,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 360 ? 11.0 : width < 400 ? 12.0 : 13.0;
    final parts = time
        .split(RegExp(r'\s*&\s*'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    final lines = parts.isEmpty ? <String>[time] : parts;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Text(
              line,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}
