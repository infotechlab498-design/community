import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/phone_launcher.dart';
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
  String _activeRoute = CommunityRepository.shuttleFromLillyA;
  Timer? _clock;
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNext());
  }

  @override
  void dispose() {
    _clock?.cancel();
    _listController.dispose();
    super.dispose();
  }

  ShuttleScheduleSnapshot get _schedule =>
      CommunityRepository.getShuttleSchedule(_activeRoute);

  void _selectRoute(String routeId) {
    setState(() => _activeRoute = routeId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNext());
  }

  void _scrollToNext() {
    if (!_listController.hasClients) return;
    final snapshot = _schedule;
    final next = snapshot.nextDeparture;
    if (next == null) return;
    final index = snapshot.route.departures.indexWhere((d) => d.id == next.id);
    if (index < 0) return;
    const rowHeight = 64.0;
    final offset = (index * rowHeight).clamp(
      0.0,
      _listController.position.maxScrollExtent,
    );
    _listController.animateTo(
      offset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _schedule;
    final route = snapshot.route;

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
              'Official departure times between Lilly A and Main Gate. The next trip is highlighted automatically.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _RouteToggle(
              activeRoute: _activeRoute,
              onSelect: _selectRoute,
            ),
            const SizedBox(height: 20),
            _NextTripCard(snapshot: snapshot),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.directionLabel,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${route.departures.length} trips today',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F8),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                height: 420,
                child: ListView.separated(
                  controller: _listController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: route.departures.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                  ),
                  itemBuilder: (context, index) {
                    final item = route.departures[index];
                    return _DepartureRow(
                      departure: item,
                      status: snapshot.statusFor(item),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SupportCard(
              onCall: () => PhoneLauncher.makePhoneCall(
                context,
                AppStrings.phoneBuildingMaintenance,
              ),
            ),
            const SizedBox(height: 16),
            const _TravelNoticeCard(),
            const SizedBox(height: 16),
            _RouteSummaryCard(route: route),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RouteToggle extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String> onSelect;

  const _RouteToggle({
    required this.activeRoute,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0x1F898989),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: 'From Lilly A',
            selected: activeRoute == CommunityRepository.shuttleFromLillyA,
            onTap: () => onSelect(CommunityRepository.shuttleFromLillyA),
          ),
          _ToggleTab(
            label: 'From Main Gate',
            selected: activeRoute == CommunityRepository.shuttleFromMainGate,
            onTap: () => onSelect(CommunityRepository.shuttleFromMainGate),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: selected
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
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _NextTripCard extends StatelessWidget {
  final ShuttleScheduleSnapshot snapshot;

  const _NextTripCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final next = snapshot.nextDeparture;
    if (next == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot.isTomorrow ? 'First trip tomorrow' : 'Next shuttle',
            style: const TextStyle(
              color: Color(0xFFF2EBFF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next.time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            snapshot.route.directionLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            snapshot.nextCountdownLabel(),
            style: const TextStyle(
              color: Color(0xFFF8F8FF),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartureRow extends StatelessWidget {
  final ShuttleDeparture departure;
  final ShuttleTripStatus status;

  const _DepartureRow({
    required this.departure,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isNext = status == ShuttleTripStatus.next;
    final isDeparted = status == ShuttleTripStatus.departed;
    final label = switch (status) {
      ShuttleTripStatus.departed => 'Departed',
      ShuttleTripStatus.next => 'Next',
      ShuttleTripStatus.upcoming => 'Upcoming',
    };

    return Container(
      color: isNext ? const Color(0xFFF3E8FF) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 108,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isNext ? AppColors.primaryPurple : AppColors.lightPurpleBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              departure.time,
              style: TextStyle(
                color: isNext
                    ? Colors.white
                    : isDeparted
                        ? AppColors.textSubtle
                        : AppColors.primaryPurple,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: isDeparted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isNext ? AppColors.primaryPurple : AppColors.textMuted,
                fontSize: 13,
                fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          if (isNext)
            const Icon(Icons.directions_bus_filled, color: AppColors.primaryPurple, size: 20),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final VoidCallback onCall;

  const _SupportCard({required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightPinkPill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onCall,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(AppAssets.needHelp, width: 44, height: 42),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Need a ride update? Call community support.',
                  style: TextStyle(
                    color: AppColors.brandMagenta,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.phone, color: AppColors.brandMagenta, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelNoticeCard extends StatelessWidget {
  const _TravelNoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightPinkPill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(AppAssets.travelIcon, width: 24, height: 24),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Travel Notice',
                  style: TextStyle(
                    color: AppColors.brandMagenta,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Allow extra time during morning peak (08:00–10:00). Rain and gate traffic can delay the shuttle.',
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
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final ShuttleRoute route;

  const _RouteSummaryCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 168,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.serviceMapPreview),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x997C3AED), Color(0xE67C3AED)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Image.asset(
                    AppAssets.mapIcon,
                    width: 14,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Community shuttle route',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${route.origin}  ↔  ${route.destination}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'First ${route.departures.first.time} · Last ${route.departures.last.time}',
                style: const TextStyle(
                  color: Color(0xFFF2EBFF),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
