import 'package:flutter/material.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/design_system/notixa_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Welcome to Notixa',
      'subtitle': 'Your AI personal assistant for instant voice notes, scheduled meetings, and smart expense tracking.',
      'icon': Icons.auto_awesome,
      'color': NotixaPalette.primary,
    },
    {
      'title': 'Speak Freely',
      'subtitle': 'Record natural voice notes. Notixa converts speech into structured tasks, calendar appointments, and financial records.',
      'icon': Icons.mic_none,
      'color': NotixaPalette.tertiary,
    },
    {
      'title': 'Smart Wallet & Expenses',
      'subtitle': 'Keep track of all your income (Received) and expenses (Spent) with automatic categorizations and currency support.',
      'icon': Icons.account_balance_wallet_outlined,
      'color': NotixaPalette.received,
    },
    {
      'title': 'Schedule & Alarms',
      'subtitle': 'Never miss a meeting. Notixa automatically syncs with your calendar and sounds proactive reminders.',
      'icon': Icons.calendar_month_outlined,
      'color': NotixaPalette.secondary,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onFinish,
                child: const Text('Skip', style: TextStyle(fontSize: 15)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: (slide['color'] as Color).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 60,
                            color: slide['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Step Indicator & Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == idx ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == idx
                              ? NotixaPalette.primary
                              : (isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  NotixaButton(
                    label: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
