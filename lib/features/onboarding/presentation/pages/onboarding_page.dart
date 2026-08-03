import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      icon: Icons.point_of_sale,
      title: 'Manual Sales',
      description: 'Quickly add products to your cart and complete sales with a simple, manual workflow.',
      color: Color(0xFF4CAF50),
    ),
    OnboardingData(
      icon: Icons.inventory_2,
      title: 'Manage Inventory',
      description: 'Add, edit, and track your products. Keep stock levels updated in real-time.',
      color: Color(0xFF2196F3),
    ),
    OnboardingData(
      icon: Icons.receipt_long,
      title: 'Digital Receipts',
      description: 'Review sale totals clearly at checkout and keep accurate transaction history.',
      color: Color(0xFFFF9800),
    ),
    OnboardingData(
      icon: Icons.store,
      title: 'Customize Shop',
      description: 'Personalize your shop details, logo, and receipt settings to match your brand.',
      color: Color(0xFF9C27B0),
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

  void _continueToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // Mark onboarding as completed
    Hive.box('settings').put('onboardingComplete', true);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Bottom section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Page indicators
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: List.generate(
                       _pages.length,
                       (i) => AnimatedContainer(
                         duration: const Duration(milliseconds: 300),
                         margin: const EdgeInsets.symmetric(horizontal: 4),
                         height: 8,
                         width: _currentPage == i ? 24 : 8,
                         decoration: BoxDecoration(
                           color: _currentPage == i
                               ? Theme.of(context).primaryColor
                               : Colors.grey[300],
                           borderRadius: BorderRadius.circular(4),
                         ),
                       ),
                     ),
                   ),
                  const SizedBox(height: 32),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continueToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 120,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
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
