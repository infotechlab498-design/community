import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class SupportGoalItem {
  final int id;
  final String title;
  final FaIconData icon;
  final Color color;

  SupportGoalItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class HelpScreen extends StatelessWidget {
  final bool showBackButton;

  const HelpScreen({super.key, this.showBackButton = true});

  void _copyAccountNumber(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: AppStrings.easyPaisaAccountNumber));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copied'),
        content: const Text(
          'Account number ${AppStrings.easyPaisaAccountNumber} copied to clipboard!',
        ),
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
    final List<SupportGoalItem> supportItems = [
      SupportGoalItem(
        id: 1,
        title: 'Keep the app running',
        icon: FontAwesomeIcons.rocket,
        color: AppColors.softPink,
      ),
      SupportGoalItem(
        id: 2,
        title: 'Pay server costs',
        icon: FontAwesomeIcons.server,
        color: AppColors.primaryPurple,
      ),
      SupportGoalItem(
        id: 3,
        title: 'Continue development',
        icon: FontAwesomeIcons.code,
        color: AppColors.emergencyRed,
      ),
      SupportGoalItem(
        id: 4,
        title: 'Add more community features',
        icon: FontAwesomeIcons.users,
        color: const Color(0xFFA21CAF),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: HeaderTopAppBar(showBackButton: showBackButton),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Information Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xBBFEE2E2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.waterDarkGreen,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.profile,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.primaryPurple.withAlpha(50),
                              child: const Icon(Icons.person, size: 40, color: AppColors.primaryPurple),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.maintainerName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          AppStrings.maintainerPhone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x99F3E8FF),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.settings, size: 13, color: AppColors.primaryPurple),
                              SizedBox(width: 4),
                              Text(
                                'APP SUPPORT & MAINTENANCE',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section Header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Support by Appreciation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Support Goals List
            ...supportItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: FaIcon(
                        item.icon,
                        size: 18,
                        color: item.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // EasyPaisa Payment Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.easyPaisaPurple1, AppColors.easyPaisaPurple2],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.easyPaisaPurple2.withAlpha(100),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 18,
                          color: AppColors.easyPaisaPurple2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SUPPORT VIA EASYPAISA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                AppStrings.easyPaisaAccountNumber,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => _copyAccountNumber(context),
                                child: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.maintainerName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                border: Border(
                  left: BorderSide(color: Color(0xFFD1D5DB), width: 4),
                ),
              ),
              child: const Text(
                "Support is completely optional. There is no compulsion. It's your choice.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            const Center(
              child: Column(
                children: [
                  Text(
                    'Thank You ≡ ❤️',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'BUILDING BETTER NEIGHBORHOODS',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
