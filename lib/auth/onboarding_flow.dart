import 'package:flutter/material.dart';
import 'onboarding_screens.dart';

import '../ui/main_navigation.dart';


class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TogetherApartScreen(onNext: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }),
    );
  }
}
