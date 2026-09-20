import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'prayer_preferences.dart';

class PrayerSettingsScreen extends StatelessWidget {
  const PrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = PrayerPreferences.instance;
    return Scaffold(
      backgroundColor: AppColors.prayerBackground,
      appBar: AppBar(
        title: const Text('Prayer settings'),
        backgroundColor: AppColors.prayerBackground,
      ),
      body: ListenableBuilder(
        listenable: preferences,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.largeAll,
                  boxShadow: AppShadows.soft,
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: const Text(
                    '24-hour time',
                    style: TextStyle(
                      color: AppColors.prayerNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Use 24-hour format for prayer times',
                    style: TextStyle(
                      color: AppColors.prayerMuted,
                      fontSize: 13,
                    ),
                  ),
                  value: preferences.use24Hour,
                  activeThumbColor: AppColors.primaryPurple,
                  onChanged: preferences.setUse24Hour,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
