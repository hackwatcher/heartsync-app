import 'package:flutter/material.dart';

class SyncMotion {
  // The signature cubic-bezier(0.34, 1.56, 0.64, 1)
  static const Curve springCurve = Cubic(0.34, 1.56, 0.64, 1.0);
  
  static const Duration short = Duration(milliseconds: 300);
  static const Duration standard = Duration(milliseconds: 400);
  static const Duration long = Duration(milliseconds: 600);
  
  // Animation for page transitions (Cross-dissolve)
  static Route createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
