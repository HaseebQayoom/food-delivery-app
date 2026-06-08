import 'package:flutter/widgets.dart';
import 'package:food_delivery/models/onboard_model.dart';

List<OnboardModel> onboardingData = [
  OnboardModel(
    badge: 'Variety',
    img: Image.asset(
      'assets/images/image1.jpg',
      fit: BoxFit.fill,
      height: 450,
      width: double.infinity,
    ),
    title: 'Anything you crave,\ndelivered fast.',
    body:
        'From smash burgers to truffle pizza — 400+ kitchens in your city, ready in 30 minutes.',
    color: const Color(0xFFFFE8DC),
    bName: 'Skip',
    bColor: Color.fromRGBO(255, 255, 255, 0.9),
  ),
  OnboardModel(
    img: Image.asset(
      'assets/images/image2.jpg',
      fit: BoxFit.cover,
      height: 450,
    ),
    title: 'Built around\nyour taste.',
    body:
        'Tell us what you love. Crave learns your habits and surfaces dishes you\'ll actually eat.',
    color: const Color(0xFFE8F4E5),
    badge: 'Personal',
    bName: 'Personalize',
    bColor: Color.fromRGBO(255, 255, 255, 0.7),
  ),
  OnboardModel(
    badge: 'Live',
    img: Image.asset(
      'assets/images/image3.jpg',
      fit: BoxFit.fill,
      height: 450,
    ),
    title: 'Track every\nbite live.',
    body:
        'Watch your courier in real time, chat with the kitchen, and never wonder where dinner is.',
    color: const Color(0xFFFFF1D6),
    bName: 'Track',
    bColor: Color.fromRGBO(255, 255, 255, 0.7),
  ),
];
