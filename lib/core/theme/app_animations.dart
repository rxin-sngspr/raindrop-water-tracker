import 'package:flutter/material.dart';

/// Duration and curve tokens for consistent animation behavior.
class AppAnimations {
  AppAnimations._();

  // ── Durations ──
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration enter = Duration(milliseconds: 600);

  // ── Curves ──
  static const Curve standard = Curves.easeOutCubic;
  static const Curve entrance = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve emphasis = Curves.easeInOutQuint;
}
