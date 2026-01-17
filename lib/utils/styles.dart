import 'package:flutter/material.dart';

class AppStyles {
  // Prevent instantiation
  AppStyles._();

  static final Gradient pinkGradient = LinearGradient(
    colors: [Colors.pink[400]!, Colors.pink[200]!],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
