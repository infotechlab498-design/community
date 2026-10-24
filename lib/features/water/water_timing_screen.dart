import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/responsive/layout_breakpoints.dart';
import '../../data/models/contact_model.dart';
import '../../data/repositories/contacts_repository.dart';
import '../../shared/widgets/async_state_views.dart';
import '../../data/models/water_schedule_model.dart';
import '../../data/repositories/community_repository.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class WaterTimingScreen extends StatefulWidget {
  final bool showBackButton;
  final bool isActive;

  const WaterTimingScreen({
    super.key,
    this.showBackButton = false,
    this.isActive = true,
  });

  @override
  State<WaterTimingScreen> createState() => _WaterTimingScreenState();
}

class _WaterTimingScreenState extends State<WaterTimingScreen> {
  final ContactsRepository _contactsRepository = ContactsRepository();
  List<WaterScheduleItem> _schedule = [];
  List<CommunityContact> _supportContacts = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(WaterTimingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_schedule.isEmpty) setState(() => _isLoading = true);
    _loadSupportContacts();
    try {
      final data = await CommunityRepository.loadWaterSchedule();
      data.sort((a, b) => a.sortKey.compareTo(b.sortKey));
      if (mounted) {
        setState(() {
          _schedule = data;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not load the saved water schedule.';
        });
      }
    }
  }

  Future<void> _loadSupportContacts() async {
    try {
      final contacts = await _contactsRepository.fetchContacts(
          category: ContactCategory.water);
      if (mounted) setState(() => _supportContacts = contacts);
    } on ApiException {
      // The schedule is still shown without the support number.
    }
  }

  int get _todayIndex {
    // Dart: 1=Mon, ..., 6=Sat, 7=Sun.
    // React Native getDay(): 0=Sun, 1=Mon, ..., 6=Sat.
    final now = DateTime.now();
    return now.weekday == 7 ? 0 : now.weekday;
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final website = LayoutBreakpoints.useWebsiteLayout(context);
    if (website) {
      return const EdgeInsets.fromLTRB(28, 24, 28, 40);
    }
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360 ? 16.0 : width < 400 ? 20.0 : 24.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  Widget _heroCard({required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
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
    );
  }

  Widget _todayCard({
    required bool todayIsOpen,
    required String todayTimeText,
  }) {
    return Container(
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
                  todayIsOpen ? 'Open today' : 'Closed today',
                  style: const TextStyle(
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
    );
  }

  Widget _scheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (_error != null && _schedule.isEmpty)
          ErrorStateView(message: _error!, onRetry: _loadData)
        else if (_schedule.isEmpty)
          const EmptyStateView(
            icon: Icons.water_drop_outlined,
            title: 'No water timings yet',
            message: 'The weekly water schedule has not been published.',
          )
        else
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
      ],
    );
  }

  Widget _supportSection() {
    if (_supportContacts.isEmpty) return const SizedBox.shrink();
    return Container(
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
          for (final contact in _supportContacts) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Image.asset(
                  AppAssets.phoneIcon,
                  width: 24,
                  height: 26,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      PlainPhoneText(
                        contact.phoneNumber ??
                            contact.description ??
                            'Number coming soon',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayItem = _schedule.cast<WaterScheduleItem?>().firstWhere(
          (item) => item?.id == _todayIndex,
          orElse: () => null,
        );
    final todayTimeText =
        todayItem?.time ?? '9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM';
    final todayIsOpen = (todayItem?.status ?? 'Open').toLowerCase() != 'closed';
    final website = LayoutBreakpoints.useWebsiteLayout(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar:
          buildHeaderTopAppBar(context, showBackButton: widget.showBackButton),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            )
          : SingleChildScrollView(
              padding: _pagePadding(context),
              child: website
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Water plant timing',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Weekly filtration plant schedule for the community.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _heroCard(height: 240),
                                  const SizedBox(height: 20),
                                  _todayCard(
                                    todayIsOpen: todayIsOpen,
                                    todayTimeText: todayTimeText,
                                  ),
                                  const SizedBox(height: 20),
                                  _supportSection(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 6,
                              child: _scheduleSection(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroCard(height: 200),
                        const SizedBox(height: 20),
                        _todayCard(
                          todayIsOpen: todayIsOpen,
                          todayTimeText: todayTimeText,
                        ),
                        const SizedBox(height: 24),
                        _scheduleSection(),
                        const SizedBox(height: 20),
                        _supportSection(),
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
