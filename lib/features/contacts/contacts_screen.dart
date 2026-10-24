import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/hospital_model.dart';
import '../../data/repositories/contacts_repository.dart';
import '../../data/repositories/hospitals_repository.dart';
import '../../shared/widgets/async_state_views.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class ContactsScreen extends StatefulWidget {
  final bool showBackButton;

  const ContactsScreen({super.key, this.showBackButton = true});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactsRepository _contactsRepository = ContactsRepository();
  final HospitalsRepository _hospitalsRepository = HospitalsRepository();

  List<CommunityContact> _contacts = const [];
  List<Hospital> _hospitals = const [];
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
      final results = await Future.wait([
        _contactsRepository.fetchContacts(),
        _hospitalsRepository.fetchHospitals(),
      ]);
      if (!mounted) return;
      setState(() {
        _contacts = results[0] as List<CommunityContact>;
        _hospitals = results[1] as List<Hospital>;
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

  List<CommunityContact> _inCategory(String category) =>
      _contacts.where((c) => c.category == category).toList();

  Future<void> _openInMaps(Hospital hospital) async {
    final opened = await launchUrl(
      hospital.mapsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: buildHeaderTopAppBar(context, showBackButton: widget.showBackButton),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                'Essential community services and emergency responders.\nLong-press a number to copy it.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ..._buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_loading && _contacts.isEmpty && _hospitals.isEmpty) {
      return const [LoadingStateView(message: 'Loading contacts…')];
    }
    if (_error != null && _contacts.isEmpty && _hospitals.isEmpty) {
      return [ErrorStateView(message: _error!, onRetry: _load)];
    }
    if (_contacts.isEmpty && _hospitals.isEmpty) {
      return const [
        EmptyStateView(
          icon: Icons.contact_phone_outlined,
          title: 'No contacts yet',
          message: 'Community contact numbers will appear here once added.',
        ),
      ];
    }

    final emergency = _inCategory(ContactCategory.emergency);
    final security = _inCategory(ContactCategory.security);
    final maintenance = _inCategory(ContactCategory.maintenance);

    return [
      for (var i = 0; i < emergency.length; i++)
        _EmergencyCard(contact: emergency[i], style: _emergencyStyles[i % _emergencyStyles.length]),
      if (emergency.isNotEmpty) const SizedBox(height: 16),
      if (security.isNotEmpty)
        _DirectorySection(
          title: 'Security and Safety',
          badge: '24/7 Available',
          contacts: security,
        ),
      if (maintenance.isNotEmpty)
        _DirectorySection(
          title: 'Maintenance & Repairs',
          contacts: maintenance,
        ),
      _HospitalsSection(hospitals: _hospitals, onOpen: _openInMaps),
    ];
  }
}

class _EmergencyStyle {
  final Gradient? gradient;
  final Color? background;
  final Color textColor;

  const _EmergencyStyle({this.gradient, this.background, this.textColor = Colors.white});
}

const List<_EmergencyStyle> _emergencyStyles = [
  _EmergencyStyle(
    gradient: LinearGradient(colors: [AppColors.fireDarkRed, AppColors.fireLightRed]),
  ),
  _EmergencyStyle(background: AppColors.primaryPurple),
  _EmergencyStyle(
    gradient: LinearGradient(colors: [Color(0xFF2C3436), Color(0xFF747C7E)]),
  ),
  _EmergencyStyle(
    gradient: LinearGradient(colors: [AppColors.fireDarkRed, AppColors.fireLightRed]),
  ),
  _EmergencyStyle(background: Color(0xFFDEED3A), textColor: AppColors.textDark),
  _EmergencyStyle(background: AppColors.primaryPurple),
];

String _badgeFor(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('medical') || lower.contains('hospital') || lower.contains('ambulance')) {
    return AppAssets.medicalIcon;
  }
  if (lower.contains('police') || lower.contains('security')) {
    return AppAssets.policeIcon;
  }
  return AppAssets.fireIcon;
}

String _serviceIconFor(CommunityContact contact) {
  final lower = contact.name.toLowerCase();
  if (lower.contains('gate')) return AppAssets.communityGateIcon;
  if (lower.contains('patrol') || lower.contains('security')) return AppAssets.neighborhoodPatrol;
  if (lower.contains('plumb') || lower.contains('water')) return AppAssets.plumbing;
  if (lower.contains('electric') || lower.contains('power')) return AppAssets.electricity;
  if (contact.category == ContactCategory.security) return AppAssets.neighborhoodPatrol;
  return AppAssets.buildingMain;
}

class _EmergencyCard extends StatelessWidget {
  final CommunityContact contact;
  final _EmergencyStyle style;

  const _EmergencyCard({required this.contact, required this.style});

  @override
  Widget build(BuildContext context) {
    final numberStyle = TextStyle(
      color: style.textColor,
      fontSize: 15,
      fontWeight: FontWeight.bold,
      height: 1.4,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: style.gradient,
        color: style.background,
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
            children: [
              Expanded(
                child: Text(
                  contact.name,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Image.asset(_badgeFor(contact.name), width: 28, height: 28, fit: BoxFit.contain),
            ],
          ),
          const SizedBox(height: 8),
          if (contact.phoneNumber != null) PlainPhoneText(contact.phoneNumber!, style: numberStyle),
          if (contact.secondaryNumber != null)
            PlainPhoneText(contact.secondaryNumber!, style: numberStyle),
          if (contact.phoneNumber == null && contact.secondaryNumber == null)
            Text(contact.description ?? 'Number coming soon', style: numberStyle),
        ],
      ),
    );
  }
}

class _DirectorySection extends StatelessWidget {
  final String title;
  final String? badge;
  final List<CommunityContact> contacts;

  const _DirectorySection({required this.title, this.badge, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0x1FDFEAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderCard),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x8FFACC15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.noticeGoldText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final contact in contacts) _ServiceRow(contact: contact),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final CommunityContact contact;

  const _ServiceRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    final numbers = [contact.phoneNumber, contact.secondaryNumber].whereType<String>().toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Image.asset(_serviceIconFor(contact), width: 40, height: 40, fit: BoxFit.contain),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                for (final number in numbers)
                  PlainPhoneText(
                    number,
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (contact.description != null)
                  Text(
                    contact.description!,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalsSection extends StatelessWidget {
  final List<Hospital> hospitals;
  final ValueChanged<Hospital> onOpen;

  const _HospitalsSection({required this.hospitals, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Hospitals',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap a hospital to open its location in Google Maps.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (hospitals.isEmpty)
          const EmptyStateView(
            icon: Icons.local_hospital_outlined,
            title: 'No hospitals listed',
            message: 'Hospital locations will appear here once added.',
          )
        else
          for (final hospital in hospitals)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => onOpen(hospital),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.lightPurpleBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_hospital_rounded, color: AppColors.primaryPurple),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hospital.name,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hospital.address,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new_rounded, color: AppColors.primaryPurple, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 24),
      ],
    );
  }
}
