import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary    = Color(0xFFE85D04); // naranja SurtiNova
  static const Color primaryDark= Color(0xFFC44D03);
  static const Color bgWhite    = Color(0xFFFFFFFF);
  static const Color bgGrey     = Color(0xFFF5F5F5);
  static const Color textDark   = Color(0xFF1A1A1A);
  static const Color textGrey   = Color(0xFF9E9E9E);
  static const Color stockGreen = Color(0xFF4CAF50);
  static const Color priceOrange= Color(0xFFE85D04);

  static ThemeData get theme => ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: bgGrey,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}