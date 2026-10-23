import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../data/models/gym_schedule_model.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/gym_repository.dart';
import '../../shared/widgets/async_state_views.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class GymTimingScreen extends StatefulWidget {
  final bool showBackButton;

  const GymTimingScreen({super.key, this.showBackButton = true});

  @override
  State<GymTimingScreen> createState() => _GymTimingScreenState();
}

class _GymTimingScreenState extends State<GymTimingScreen> {
  final GymRepository _repository = GymRepository();
  List<GymSession> _sessions = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sessions = await _repository.fetchSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GymDayItem> weekDates = CommunityRepository.getCurrentWeekDates();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: HeaderTopAppBar(showBackButton: widget.showBackButton),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const Text(
                'GYM',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'SCHEDULE',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daily training blocks for residents. Timings apply every day of the week.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              _WeekStrip(weekDates: weekDates),
              const SizedBox(height: 24),
              ..._buildSessions(),
              const SizedBox(height: 20),
              const _InfoBanner(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSessions() {
    if (_loading && _sessions.isEmpty) {
      return const [LoadingStateView(message: 'Loading gym timings…')];
    }
    if (_error != null && _sessions.isEmpty) {
      return [ErrorStateView(message: _error!, onRetry: _load)];
    }
    if (_sessions.isEmpty) {
      return const [
        EmptyStateView(
          icon: Icons.fitness_center_outlined,
          title: 'No gym sessions yet',
          message: 'Gym timings will appear here once the admin adds them.',
        ),
      ];
    }
    final now = DateTime.now();
    return [
      for (final session in _sessions) ...[
        _SessionCard(session: session, now: now),
        const SizedBox(height: 16),
      ],
    ];
  }
}

class _WeekStrip extends StatelessWidget {
  final List<GymDayItem> weekDates;

  const _WeekStrip({required this.weekDates});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = weekDates[index];
          return Container(
            width: 68,
            decoration: BoxDecoration(
              color: item.isToday ? AppColors.gymPurple : const Color(0xFFEDE3E3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: item.isToday
                  ? [
                      BoxShadow(
                        color: AppColors.gymPurple.withAlpha(80),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.dayName,
                  style: TextStyle(
                    color: item.isToday ? Colors.white : AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.date}',
                  style: TextStyle(
                    color: item.isToday ? Colors.white : AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final GymSession session;
  final DateTime now;

  const _SessionCard({required this.session, required this.now});

  @override
  Widget build(BuildContext context) {
    final isFemale = session.audience == GymAudience.female;
    final live = session.isLive(now);
    final ended = !live &&
        now.hour * 60 + now.minute >= apiTimeToMinutes(session.endTime);
    final statusLabel = live ? 'OPEN NOW' : (ended ? 'ENDED TODAY' : 'UPCOMING');
    final statusColor = live
        ? AppColors.waterGreen
        : (ended ? AppColors.textSubtle : AppColors.gymPurple);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: live ? AppColors.waterGreen : const Color(0x1F000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${session.audienceLabel.toUpperCase()} SESSION',
                  style: const TextStyle(
                    color: AppColors.gymPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${isFemale ? '♀' : '♂'} ${session.title}',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session.timeRangeLabel,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'RESIDENTS ONLY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'CARRY YOUR RESIDENT CARD',
            style: TextStyle(
              color: AppColors.gymPurple,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
