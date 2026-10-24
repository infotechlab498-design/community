import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:community/core/constants/app_colors.dart';
import 'package:community/core/responsive/layout_breakpoints.dart';
import 'package:community/features/home/home_screen.dart';
import 'package:community/features/more/more_screen.dart';
import 'package:community/features/shuttle/shuttle_service_screen.dart';
import 'package:community/features/water/water_supply_screen.dart';
import 'package:community/features/water/water_timing_screen.dart';
import 'package:community/features/website/web_home_page.dart';
import 'package:community/features/website/website_frame.dart';
import 'package:community/features/main_shell/shell_navigation.dart';

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

  int get currentIndex => _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    ShellNavigation.instance.setIndex(_currentIndex);
    ShellNavigation.instance.addListener(_onShellNav);
  }

  void _onShellNav() {
    final next = ShellNavigation.instance.index;
    if (next != _currentIndex && mounted) {
      setState(() => _currentIndex = next);
    }
  }

  @override
  void dispose() {
    ShellNavigation.instance.removeListener(_onShellNav);
    super.dispose();
  }

  void switchTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() => _currentIndex = index);
      ShellNavigation.instance.setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final website = LayoutBreakpoints.useWebsiteLayout(context);

    final List<Widget> tabs = [
      website
          ? WebHomePage(onNavigateToTab: switchTab)
          : HomeScreen(onNavigateToTab: switchTab),
      WaterTimingScreen(isActive: _currentIndex == 1),
      const WaterSupplyScreen(),
      const ShuttleServiceScreen(),
      MoreScreen(showBackButton: false, websiteLayout: website),
    ];

    if (website) {
      // Website chrome lives here so header can sync with this shell.
      return WebsiteFrame(
        child: ColoredBox(
          color: AppColors.surfaceLight,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _currentIndex == 0
                    ? double.infinity
                    : LayoutBreakpoints.contentMaxWidth(context),
              ),
              child: Material(
                color: _currentIndex == 0
                    ? Colors.transparent
                    : AppColors.backgroundWhite,
                child: IndexedStack(index: _currentIndex, children: tabs),
              ),
            ),
          ),
        ),
      );
    }

    // Existing mobile application shell — preserved.
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: switchTab,
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
