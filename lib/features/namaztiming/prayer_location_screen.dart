import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/prayer_time_model.dart';

class PrayerLocationScreen extends StatelessWidget {
  final PrayerLocation current;

  const PrayerLocationScreen({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.prayerBackground,
      appBar: AppBar(
        title: const Text('Prayer location'),
        backgroundColor: AppColors.prayerBackground,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: PrayerLocation.options.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final location = PrayerLocation.options[index];
          final selected = location.id == current.id;
          return Material(
            color: Colors.white,
            borderRadius: AppRadii.largeAll,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(location),
              borderRadius: AppRadii.largeAll,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 64),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          location.label,
                          style: const TextStyle(
                            color: AppColors.prayerNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryPurple,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
