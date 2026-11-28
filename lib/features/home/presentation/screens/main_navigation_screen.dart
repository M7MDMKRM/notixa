import 'package:flutter/material.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import 'home_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLocaleChanged;

  const MainNavigationScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeDashboardScreen(
        onNavigateToMeetings: () => setState(() => _currentIndex = 1),
      ),
      const CalendarScreen(),
      const WalletScreen(),
      ProfileScreen(
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard;
    final borderColor = isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', isDark),
            _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month, 'Meetings', isDark),
            _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Wallet', isDark),
            _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? NotixaPalette.primary.withOpacity(0.2) : NotixaPalette.purpleBadge)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? filledIcon : outlineIcon,
                color: isSelected
                    ? NotixaPalette.primary
                    : (isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? NotixaPalette.primary
                    : (isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
