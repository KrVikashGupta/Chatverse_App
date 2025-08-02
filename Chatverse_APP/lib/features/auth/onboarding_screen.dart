import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart'; // Uncomment when Lottie asset is available

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Welcome to ChatVerse',
      description: 'Connect instantly with friends and groups in real time.',
      lottieAsset: 'assets/lottie/chat.json', // Placeholder
    ),
    _OnboardingPageData(
      title: 'Share Media Effortlessly',
      description: 'Send images, audio, and files with a tap.',
      lottieAsset: 'assets/lottie/media.json', // Placeholder
    ),
    _OnboardingPageData(
      title: 'Stay Notified',
      description: 'Get instant notifications for new messages.',
      lottieAsset: 'assets/lottie/notify.json', // Placeholder
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _goToSignup() {
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie.asset(page.lottieAsset, height: 220),
                        Container(
                          height: 220,
                          width: 220,
                          color: Colors.grey.shade200,
                          child: const Center(child: Text('Lottie Animation')),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _goToLogin,
                    child: const Text('Skip'),
                  ),
                  const Spacer(),
                  if (_currentPage < _pages.length - 1)
                    FilledButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      },
                      child: const Text('Next'),
                    )
                  else ...[
                    FilledButton(
                      onPressed: _goToLogin,
                      child: const Text('Login'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _goToSignup,
                      child: const Text('Sign Up'),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String lottieAsset;
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.lottieAsset,
  });
} 