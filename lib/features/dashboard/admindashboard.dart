import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/header_top_app_bar.dart';
import '../auth/adminLogin.dart';
import 'screens/admin_contacts_screen.dart';
import 'screens/admin_gym_screen.dart';
import 'screens/admin_hospitals_screen.dart';
import 'screens/admin_prayer_times_screen.dart';
import 'screens/admin_shuttle_screen.dart';
import 'screens/admin_water_schedule_screen.dart';
import 'screens/admin_water_supply_screen.dart';

class AdminDashboard extends StatefulWidget {
  final bool showBackButton;
  const AdminDashboard({super.key, this.showBackButton = true});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final valid = await _authService.hasValidSession();
    if (!mounted) return;
    if (!valid) {
      _goToLogin('Your session has expired. Please sign in again.');
      return;
    }
    setState(() => _checkingSession = false);
  }

  void _goToLogin(String? message) {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminLoginScreen()),
      (route) => route.isFirst,
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to make changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <_DashboardTile>[
      _DashboardTile(
        icon: Icons.water_drop_outlined,
        label: 'Water Timing',
        color: const Color(0xFF0878C9),
        onTap: () => _open(const AdminWaterScheduleScreen()),
      ),
      _DashboardTile(
        icon: Icons.calendar_month_outlined,
        label: 'Water Supply',
        color: const Color(0xFF119C6B),
        onTap: () => _open(const AdminWaterSupplyScreen()),
      ),
      _DashboardTile(
        icon: Icons.mosque_outlined,
        label: 'Namaz Timing',
        color: AppColors.primaryPurple,
        onTap: () => _open(const AdminPrayerTimesScreen()),
      ),
      _DashboardTile(
        icon: Icons.directions_bus_outlined,
        label: 'Shuttle',
        color: const Color(0xFFA855F7),
        onTap: () => _open(const AdminShuttleScreen()),
      ),
      _DashboardTile(
        icon: Icons.fitness_center_outlined,
        label: 'Gym Timing',
        color: AppColors.gymPurple,
        onTap: () => _open(const AdminGymScreen()),
      ),
      _DashboardTile(
        icon: Icons.contact_phone_outlined,
        label: 'Contacts',
        color: AppColors.brandMagenta,
        onTap: () => _open(const AdminContactsScreen()),
      ),
      _DashboardTile(
        icon: Icons.local_hospital_outlined,
        label: 'Hospitals',
        color: AppColors.emergencyRed,
        onTap: () => _open(const AdminHospitalsScreen()),
      ),
      _DashboardTile(
        icon: Icons.logout_rounded,
        label: 'Logout',
        color: AppColors.textMuted,
        onTap: _logout,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: HeaderTopAppBar(showBackButton: widget.showBackButton),
      body: _checkingSession
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose what you want to update. Changes appear in the app straight away.',
                  style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 520 ? 3 : 2;
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: tiles,
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
