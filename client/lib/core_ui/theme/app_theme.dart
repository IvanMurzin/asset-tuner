import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(colorScheme: _lightScheme());
final ThemeData darkTheme = ThemeData(colorScheme: _darkScheme());

ColorScheme _lightScheme() {
  return const ColorScheme.light();
}

ColorScheme _darkScheme() {
  return const ColorScheme.dark();
}
