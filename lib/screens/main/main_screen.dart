import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'insights_screen.dart';
import '../settings/settings_screen.dart';
import '../../providers/navigation_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: _screens[navigationProvider.selectedIndex],
      bottomNavigationBar: _buildCurvedBottomNavigationBar(
        context,
        navigationProvider,
        theme,
      ),
    );
  }

  Widget _buildCurvedBottomNavigationBar(
    BuildContext context,
    NavigationProvider navigationProvider,
    ThemeData theme,
  ) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                index: 0,
                isSelected: navigationProvider.selectedIndex == 0,
                onTap: () => navigationProvider.setIndex(0),
                theme: theme,
              ),
              _buildNavItem(
                context,
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.calendar_today,
                index: 1,
                isSelected: navigationProvider.selectedIndex == 1,
                onTap: () => navigationProvider.setIndex(1),
                theme: theme,
              ),
              _buildNavItem(
                context,
                icon: Icons.insights_outlined,
                selectedIcon: Icons.insights,
                index: 2,
                isSelected: navigationProvider.selectedIndex == 2,
                onTap: () => navigationProvider.setIndex(2),
                theme: theme,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                index: 3,
                isSelected: navigationProvider.selectedIndex == 3,
                onTap: () => navigationProvider.setIndex(3),
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isSelected ? selectedIcon : icon,
          size: 28,
          color: theme.brightness == Brightness.dark
              ? (isSelected ? Colors.white : Colors.grey.shade400)
              : (isSelected ? Colors.black : Colors.grey.shade600),
        ),
      ),
    );
  }
}
