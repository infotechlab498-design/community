import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool showBackButton;

  const PrivacyPolicyScreen({super.key, this.showBackButton = true});

  Future<void> _openHostedPolicy(BuildContext context) async {
    final url = AppStrings.privacyPolicyUrl.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The hosted privacy policy link will appear here once published.')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: HeaderTopAppBar(showBackButton: showBackButton),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        children: [
          const Text(
            AppStrings.privacyPolicyTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Last updated: 18 September 2026',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          const Text(
            AppStrings.privacyPolicyBody,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _openHostedPolicy(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: const BorderSide(color: AppColors.primaryPurple),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open full privacy policy'),
          ),
        ],
      ),
    );
  }
}
