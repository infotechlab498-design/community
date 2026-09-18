import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/phone_launcher.dart';
import '../../shared/widgets/header_top_app_bar.dart';
import '../hospital_map/hospital_map_widget.dart';

class ContactsScreen extends StatelessWidget {
  final bool showBackButton;

  const ContactsScreen({super.key, this.showBackButton = true});

  Widget _buildEmergencyCard(
    BuildContext context, {
    required String title,
    required String numberText,
    required String dialNumber,
    required String badgeIcon,
    Gradient? gradient,
    Color? backgroundColor,
    Color textColor = Colors.white,
    Color titleColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Image.asset(
                    badgeIcon,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => PhoneLauncher.makePhoneCall(context, dialNumber),
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      AppAssets.phoneIcon2,
                      width: 48,
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => PhoneLauncher.makePhoneCall(context, dialNumber),
            child: Text(
              numberText,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(
    BuildContext context, {
    required String iconAsset,
    required String title,
    required String subtitle,
    String? phoneNumber,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x3B216C8C)),
      ),
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (phoneNumber != null)
            InkWell(
              onTap: () => PhoneLauncher.makePhoneCall(context, phoneNumber),
              child: Image.asset(
                AppAssets.gatePhone,
                width: 36,
                height: 36,
              ),
            )
          else
            Image.asset(
              AppAssets.gatePhone,
              width: 36,
              height: 36,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: HeaderTopAppBar(showBackButton: showBackButton),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Important Numbers',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Quick access to essential community\nservices and emergency responders.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Cards
            _buildEmergencyCard(
              context,
              title: 'Fire Department',
              numberText: AppStrings.phoneFire1122,
              dialNumber: AppStrings.phoneFire1122,
              badgeIcon: AppAssets.fireIcon,
              gradient: const LinearGradient(
                colors: [AppColors.fireDarkRed, AppColors.fireLightRed],
              ),
            ),
            _buildEmergencyCard(
              context,
              title: 'Medical Emergency',
              numberText: '${AppStrings.phoneMedicalEmergency}\n${AppStrings.phoneMedicalLandline}',
              dialNumber: AppStrings.phoneMedicalEmergency,
              badgeIcon: AppAssets.medicalIcon,
              backgroundColor: AppColors.primaryPurple,
            ),
            _buildEmergencyCard(
              context,
              title: 'Police Dispatch',
              numberText: AppStrings.phonePolice,
              dialNumber: AppStrings.phonePolice,
              badgeIcon: AppAssets.policeIcon,
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3436), Color(0xFF747C7E)],
              ),
            ),
            _buildEmergencyCard(
              context,
              title: 'QRF',
              numberText: AppStrings.phoneQrf,
              dialNumber: AppStrings.phoneQrf,
              badgeIcon: AppAssets.fireIcon,
              gradient: const LinearGradient(
                colors: [AppColors.fireDarkRed, AppColors.fireLightRed],
              ),
            ),
            _buildEmergencyCard(
              context,
              title: 'Fire Fighting Supervisor',
              numberText: AppStrings.phoneFireSupervisor,
              dialNumber: AppStrings.phoneFireSupervisor,
              badgeIcon: AppAssets.fireIcon,
              backgroundColor: const Color(0xFFDEED3A),
              textColor: AppColors.textDark,
              titleColor: AppColors.textDark,
            ),
            _buildEmergencyCard(
              context,
              title: 'Fire Brigade',
              numberText: AppStrings.phoneFireBrigade,
              dialNumber: AppStrings.phoneFireBrigade,
              badgeIcon: AppAssets.fireIcon,
              backgroundColor: AppColors.primaryPurple,
            ),
            const SizedBox(height: 16),

            // Security & Safety Directory
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0x1FDFEAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x3B216C8C)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Security and Safety',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x8FFACC15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '24/7 Available',
                          style: TextStyle(
                            color: AppColors.noticeGoldText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildServiceRow(
                    context,
                    iconAsset: AppAssets.communityGateIcon,
                    title: 'Community Main Gate',
                    subtitle: 'Updating Soon',
                  ),
                  _buildServiceRow(
                    context,
                    iconAsset: AppAssets.neighborhoodPatrol,
                    title: 'Neighborhood Patrol',
                    subtitle: 'Mobile Security Unit',
                  ),
                ],
              ),
            ),

            // Maintenance & Repairs Directory
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0x1FDFEAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x3B216C8C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Maintenance & Repairs',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildServiceRow(
                    context,
                    iconAsset: AppAssets.buildingMain,
                    title: 'Building Maintenance',
                    subtitle: AppStrings.phoneBuildingMaintenance,
                    phoneNumber: AppStrings.phoneBuildingMaintenance,
                  ),
                  _buildServiceRow(
                    context,
                    iconAsset: AppAssets.plumbing,
                    title: 'Emergency Plumbing',
                    subtitle: AppStrings.phoneEmergencyPlumbing,
                    phoneNumber: AppStrings.phoneEmergencyPlumbing,
                  ),
                  _buildServiceRow(
                    context,
                    iconAsset: AppAssets.electricity,
                    title: 'Electrical Services',
                    subtitle: 'Power outages & fault repairs',
                  ),
                ],
              ),
            ),

            // Embedded Hospital Map Section
            const HospitalMapWidget(),
          ],
        ),
      ),
    );
  }
}
