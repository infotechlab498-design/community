import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/prayer_time_model.dart';
import '../../data/repositories/prayer_times_repository.dart';
import 'prayer_details_screen.dart';
import 'prayer_location_screen.dart';
import 'prayer_preferences.dart';
import 'prayer_settings_screen.dart';
import 'widgets/prayer_times_widgets.dart';

class PrayerTimesScreen extends StatefulWidget {
  final bool showBackButton;

  const PrayerTimesScreen({super.key, this.showBackButton = true});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesRepository _repository = const LocalPrayerTimesRepository();
  final PrayerPreferences _preferences = PrayerPreferences.instance;

  PrayerDaySnapshot? _snapshot;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _preferences.addListener(_onPreferencesChanged);
    _load();
  }

  @override
  void dispose() {
    _preferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _snapshot == null;
      _error = false;
    });
    try {
      final snapshot = await _repository.loadSchedule(
        location: _preferences.location,
      );
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _openDetails(PrayerTime prayer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrayerDetailsScreen(
          prayer: prayer,
          snapshot: _snapshot!,
          use24Hour: _preferences.use24Hour,
        ),
      ),
    );
  }

  Future<void> _openLocation() async {
    final selected = await Navigator.of(context).push<PrayerLocation>(
      MaterialPageRoute(
        builder: (_) => PrayerLocationScreen(current: _preferences.location),
      ),
    );
    if (selected != null) {
      _preferences.setLocation(selected);
    }
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PrayerSettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final now = _snapshot?.now ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.prayerBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 360
                ? 16.0
                : AppSpacing.xl;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _buildBody(now),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(DateTime now) {
    if (_loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrayerBrandHeader(
            showBackButton: widget.showBackButton,
            onOpenSettings: _openSettings,
          ),
          const SizedBox(height: AppSpacing.lg),
          const PrayerTimesSkeleton(),
        ],
      );
    }

    if (_error || _snapshot == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrayerBrandHeader(
            showBackButton: widget.showBackButton,
            onOpenSettings: _openSettings,
          ),
          const SizedBox(height: 48),
          _ErrorCard(onRetry: _load),
        ],
      );
    }

    final snapshot = _snapshot!;
    return Stack(
      children: [
        const Positioned(top: 36, right: 0, child: MosqueSilhouette()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrayerBrandHeader(
              showBackButton: widget.showBackButton,
              onOpenSettings: _openSettings,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrayerGreeting(now: now),
            PrayerLocationButton(
              location: snapshot.location,
              onTap: _openLocation,
            ),
            const SizedBox(height: AppSpacing.lg),
            CurrentPrayerCard(
              snapshot: snapshot,
              use24Hour: _preferences.use24Hour,
              onViewAll: () => _openDetails(snapshot.currentPrayer),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrayerScheduleCard(
              snapshot: snapshot,
              use24Hour: _preferences.use24Hour,
              onSelect: _openDetails,
            ),
            const SizedBox(height: AppSpacing.lg),
            NextPrayerCard(
              snapshot: snapshot,
              use24Hour: _preferences.use24Hour,
              onTap: () => _openDetails(snapshot.nextPrayer),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.largeAll,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          const Text(
            'Prayer times couldn\'t be updated',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.prayerNavy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Check your connection or location settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.prayerMuted, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
