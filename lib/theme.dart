import 'package:flutter/material.dart';

class AppBrand {
  static const Color tokopediaGreen = Color(0xFF03AC0E);
  static const Color tokopediaGreenLight = Color(0xFF35C53C);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [tokopediaGreen, tokopediaGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
