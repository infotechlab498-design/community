import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadii {
  AppRadii._();

  static const double small = 10;
  static const double medium = 14;
  static const double large = 18;
  static const double hero = 24;

  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumAll = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(large));
  static const BorderRadius heroAll = BorderRadius.all(Radius.circular(hero));
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> hero = [
    BoxShadow(color: Color(0x337C3AED), blurRadius: 20, offset: Offset(0, 10)),
  ];
}
