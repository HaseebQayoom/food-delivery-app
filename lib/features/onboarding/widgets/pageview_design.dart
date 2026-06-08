import 'package:flutter/material.dart';
import 'package:food_delivery/models/onboard_model.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';

class PageviewDesign extends StatelessWidget {
  const PageviewDesign({
    super.key,
    required this.onboardingD,
    required this.index,
    required this.pageViewController,
  });

  final OnboardModel onboardingD;
  final int index;
  final PageController pageViewController;

  @override
  Widget build(BuildContext context) {
    final indexDisplay = index + 1;

    return Column(
      children: [
        Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: SizedBox(
            height: 450,
            width: double.infinity,
            child: Stack(
              children: [
                onboardingD.img,
                Positioned(
                  left: 20,
                  right: 20,
                  top: 20,
                  child: Row(
                    children: [
                      // Step badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: onboardingD.color,
                        ),
                        child: Text(
                          '0$indexDisplay — ${onboardingD.badge}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const Spacer(),
                      // Skip / Next button
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            if (indexDisplay == 3) {
                              AppNavigator.toAuth(context);
                            } else {
                              // Skip goes to last page
                              pageViewController.animateToPage(
                                2,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onboardingD.bColor,
                          ),
                          child: Text(
                            indexDisplay == 3 ? 'Next' : 'Skip',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.black,
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
        ),
        const SizedBox(height: 20),
        Text(
          onboardingD.title,
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          onboardingD.body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}
