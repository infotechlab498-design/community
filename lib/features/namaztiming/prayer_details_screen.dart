import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/time_formatter.dart';
import '../../data/models/prayer_time_model.dart';

class PrayerDetailsScreen extends StatelessWidget {
  final PrayerTime prayer;
  final PrayerDaySnapshot snapshot;
  final bool use24Hour;

  const PrayerDetailsScreen({
    super.key,
    required this.prayer,
    required this.snapshot,
    required this.use24Hour,
  });

  @override
  Widget build(BuildContext context) {
    final status = snapshot.rowStatus(prayer);
    final remaining = prayer.type == snapshot.nextPrayer.type
        ? snapshot.nextPrayerTime.difference(DateTime.now())
        : prayer.startTime.difference(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.prayerBackground,
      appBar: AppBar(
        title: Text(prayer.name),
        backgroundColor: AppColors.prayerBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.largeAll,
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prayer.name,
                style: const TextStyle(
                  color: AppColors.prayerNavy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  prayer.arabicName,
                  style: const TextStyle(
                    color: AppColors.prayerArabic,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _DetailLine(
                label: 'Start time',
                value: TimeFormatter.formatTime(
                  prayer.startTime,
                  use24Hour: use24Hour,
                ),
              ),
              _DetailLine(
                label: 'Status',
                value: switch (status) {
                  PrayerRowStatus.current => 'Currently active',
                  PrayerRowStatus.upcoming => 'Upcoming',
                  PrayerRowStatus.past => 'Completed',
                },
              ),
              if (!remaining.isNegative)
                _DetailLine(
                  label: 'Time remaining',
                  value: TimeFormatter.formatCountdown(remaining),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.prayerMuted,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.prayerNavy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
