import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../water/water_timing_screen.dart';
import '../water/water_supply_screen.dart';
import '../shuttle/shuttle_service_screen.dart';
import '../more/more_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainShellScreen({super.key, this.initialTabIndex = 0});

  static MainShellScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainShellScreenState>();
  }

  @override
  State<MainShellScreen> createState() => MainShellScreenState();
}

class MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void switchTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeScreen(onNavigateToTab: switchTab),
      const WaterTimingScreen(),
      const WaterSupplyScreen(),
      const ShuttleServiceScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.backgroundWhite,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.industry, size: 20),
            label: 'Water Timing',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.droplet, size: 20),
            label: 'Water Supply',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bus, size: 20),
            label: 'Shuttle',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.ellipsis, size: 20),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
