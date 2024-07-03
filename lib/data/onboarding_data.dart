import 'package:flutter/material.dart';

class OnboardingContent {
  String imagePath;
  String title;
  String description;
  Color backgroundColor;
  OnboardingContent({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}

List<OnboardingContent> contentList = [
  OnboardingContent(
    imagePath: 'assets/images/onboarding_images/onboarding-1.png',
    title: 'Welcome to Hostelite',
    description:
        'Effortlessly find and book the perfect student accommodation that suits your needs.',
   backgroundColor: const Color(0xff95B6FF),
  ),
  OnboardingContent(
    imagePath: 'assets/images/onboarding_images/onboarding-2.png',
    title: 'Discover Your Home',
    description:
        'Explore a variety of rooms and hostels near your campus with just a few taps.',
    backgroundColor: const Color(0xffB7ABFD),
  ),
  OnboardingContent(
    imagePath: 'assets/images/onboarding_images/onboarding-3.png',
    title: 'Simplify Your Stay',
    description:
        'Easily manage your bookings and enjoy a stress-free accommodation experience with Hostelite.',
    backgroundColor: const Color(0xffF0CF69),
  ),
];
