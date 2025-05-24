/* Authored by: Hazel Salvador
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-011] Darkmode
Description: Dark and Light theme for users preferences.
 */

//This code lets the app switch between dark and light modes. It saves the user's theme choice so it remembers 
//it next time. The app starts in light mode by default, but users can change it,
// and the app will save their preference.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider extends ChangeNotifier {
  // Start with light mode by default
  ThemeMode _themeMode = ThemeMode.light;

  // Get the current theme mode (light or dark)
  ThemeMode get themeMode => _themeMode;

  /// Loads the saved theme setting from SharedPreferences.
  /// If no setting is found, it uses light mode by default.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Let the app know the theme has changed
  }

  /// Switches between dark and light mode and saves the choice.
  /// The `isDark` parameter decides whether to use dark mode or light mode.
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Update the UI to reflect the new theme
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark); // Save the user's choice
  }

  /// Checks if dark mode is currently enabled.
  bool get isDarkMode => _themeMode == ThemeMode.dark;
}
