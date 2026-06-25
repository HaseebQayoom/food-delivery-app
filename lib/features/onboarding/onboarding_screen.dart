import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/providers/shared_prefs_provider.dart';
import 'package:food_delivery/features/onboarding/data/onboarding_data.dart';
import 'package:food_delivery/features/onboarding/widgets/pageview_design.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 77 / 100,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (value) =>
                      setState(() => _currentIndex = value),
                  itemBuilder: (context, index) => PageviewDesign(
                    onboardingD: onboardingData[index],
                    index: index,
                    pageViewController: _pageController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: onboardingData.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: cs.primary,
                        dotColor: const Color.fromARGB(195, 158, 158, 158),
                        dotHeight: 9,
                        dotWidth: 8,
                        expansionFactor: 3.5,
                      ),
                      onDotClicked: (index) => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary,
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (_currentIndex == onboardingData.length - 1) {
                            ref.read(sharedPrefsProvider).setBool(StorageKeys.onboardingSeen, true);
                            AppNavigator.toAuth(context);
                          } else {
                            _pageController.animateToPage(
                              _currentIndex + 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                        ),
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
