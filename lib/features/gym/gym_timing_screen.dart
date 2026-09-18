import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/gym_schedule_model.dart';
import '../../data/repositories/community_repository.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class GymTimingScreen extends StatelessWidget {
  final bool showBackButton;

  const GymTimingScreen({super.key, this.showBackButton = true});

  void _showComingSoon(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action),
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
    final List<GymDayItem> weekDates = CommunityRepository.getCurrentWeekDates();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: HeaderTopAppBar(showBackButton: showBackButton),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Header Titles
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
              'Optimized training blocks designed for peak performance and recovery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Horizontal Date Slider (Monday through Sunday)
            SizedBox(
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
            ),
            const SizedBox(height: 24),

            // Card 1: Male Morning
            _buildSessionCard(
              context,
              tag: 'PEAK PERFORMANCE',
              title: '♂ Male Morning',
              time: '10:00 AM – 12:00 PM',
              buttonText: 'JOIN NOW',
              buttonColor: AppColors.gymPurple,
              onPressed: () => _showComingSoon(context, 'Join Session'),
            ),
            const SizedBox(height: 16),

            // Card 2: Female Evening
            _buildSessionCard(
              context,
              tag: 'COMMUNITY ENERGY',
              title: '♀ Female Evening',
              time: '05:00 PM – 07:00 PM',
              buttonText: 'BOOK SLOT',
              buttonColor: const Color(0xFFBCA1F7),
              onPressed: () => _showComingSoon(context, 'Book Slot'),
            ),
            const SizedBox(height: 16),

            // Card 3: Male Night (Sold Out)
            _buildSessionCard(
              context,
              tag: 'ELITE RECOVERY',
              title: '♂ Male Night',
              time: '07:00 PM – 09:00 PM',
              buttonText: 'SOLD OUT',
              buttonColor: AppColors.gymPurple,
              isSoldOut: true,
              onPressed: () => _showComingSoon(context, 'Male Night Session'),
            ),
            const SizedBox(height: 20),

            // Exclusive Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    'AFTER HOURS ELITE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'EXCLUSIVE SESSION',
                    style: TextStyle(
                      color: AppColors.gymPurple,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
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

  Widget _buildSessionCard(
    BuildContext context, {
    required String tag,
    required String title,
    required String time,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
    bool isSoldOut = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1F000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: AppColors.gymPurple,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
