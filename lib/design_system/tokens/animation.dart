import 'package:flutter/material.dart';

class DSAnimation {
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration extraSlow = Duration(milliseconds: 400);
  
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}
