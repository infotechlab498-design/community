import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:community/features/auth/adminLogin.dart';
import 'package:community/features/contacts/contacts_screen.dart';
import 'package:community/features/gym/gym_timing_screen.dart';
import 'package:community/features/help/help_screen.dart';
import 'package:community/features/namaztiming/prayer_times_screen.dart';
import 'package:community/features/privacy/privacy_policy_screen.dart';
import 'package:community/features/updates/official_updates_screen.dart';

/// Top-level website tabs mapped to [MainShellScreen] indexes.
class WebsitePrimaryTab {
  final String label;
  final int shellIndex;
  final FaIconData icon;

  const WebsitePrimaryTab({
    required this.label,
    required this.shellIndex,
    required this.icon,
  });
}

const List<WebsitePrimaryTab> kWebsitePrimaryTabs = [
  WebsitePrimaryTab(
    label: 'Home',
    shellIndex: 0,
    icon: FontAwesomeIcons.house,
  ),
  WebsitePrimaryTab(
    label: 'Water Timing',
    shellIndex: 1,
    icon: FontAwesomeIcons.industry,
  ),
  WebsitePrimaryTab(
    label: 'Water Supply',
    shellIndex: 2,
    icon: FontAwesomeIcons.droplet,
  ),
  WebsitePrimaryTab(
    label: 'Shuttle',
    shellIndex: 3,
    icon: FontAwesomeIcons.bus,
  ),
];

class WebsiteMoreLink {
  final String label;
  final FaIconData icon;
  final WidgetBuilder builder;

  const WebsiteMoreLink({
    required this.label,
    required this.icon,
    required this.builder,
  });
}

final List<WebsiteMoreLink> kWebsiteMoreLinks = [
  WebsiteMoreLink(
    label: 'Namaz Timing',
    icon: FontAwesomeIcons.moon,
    builder: (_) => const PrayerTimesScreen(showBackButton: true),
  ),
  WebsiteMoreLink(
    label: 'Contacts',
    icon: FontAwesomeIcons.addressBook,
    builder: (_) => const ContactsScreen(showBackButton: true),
  ),
  WebsiteMoreLink(
    label: 'Gym Timing',
    icon: FontAwesomeIcons.dumbbell,
    builder: (_) => const GymTimingScreen(showBackButton: true),
  ),
  WebsiteMoreLink(
    label: 'Official Updates',
    icon: FontAwesomeIcons.bullhorn,
    builder: (_) => const OfficialUpdatesScreen(showBackButton: true),
  ),
  WebsiteMoreLink(
    label: 'Help & Support',
    icon: FontAwesomeIcons.circleQuestion,
    builder: (_) => const HelpScreen(showBackButton: true),
  ),
  WebsiteMoreLink(
    label: 'Privacy Policy',
    icon: FontAwesomeIcons.shieldHalved,
    builder: (_) => const PrivacyPolicyScreen(showBackButton: true),
  ),
  WebsiteMoreLink(
    label: 'Admin Login',
    icon: FontAwesomeIcons.userShield,
    builder: (_) => const AdminLoginScreen(),
  ),
];
