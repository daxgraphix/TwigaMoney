import 'package:twigamoney/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(AppLocalizations l10n) => [
    OnboardingData(
      icon: Icons.account_balance_wallet,
      title: l10n.onboardingTrackTitle,
      description: l10n.onboardingTrackDesc,
      color: AppTheme.primaryColor,
    ),
    OnboardingData(
      icon: Icons.inventory_2,
      title: l10n.onboardingInventoryTitle,
      description: l10n.onboardingInventoryDesc,
      color: const Color(0xFF0EA5E9),
    ),
    OnboardingData(
      icon: Icons.people_alt,
      title: l10n.onboardingCustomerTitle,
      description: l10n.onboardingCustomerDesc,
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingData(
      icon: Icons.analytics,
      title: l10n.onboardingShiftTitle,
      description: l10n.onboardingShiftDesc,
      color: const Color(0xFF10B981),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _continueToNext(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    HiveDatabase.settingsBox.put('onboardingComplete', true);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = _getPages(l10n);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.appName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                    child: Text(
                      l10n.skip,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(pages[index], isDark);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentPage == i ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppTheme.primaryColor
                              : (isDark ? Colors.white24 : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _continueToNext(pages.length),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == pages.length - 1 ? l10n.getStarted : l10n.continueText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              data.icon,
              size: 100,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.secondaryColor,
              letterSpacing: -1,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

