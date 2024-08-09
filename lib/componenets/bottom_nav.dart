import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../screens/history.dart';
import '../screens/settings.dart';
import '../screens/home_screen.dart';

BottomNavigationBar myBottomNavBar(BuildContext context, int selectedIndex,
    ThemeMode currentTheme, Function(ThemeMode) onThemeChanged, Box box) {
  return BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
    ],
    // type: BottomNavigationBarType.shifting,
    currentIndex: selectedIndex,
    elevation: 80,
    onTap: (index) {
      selectRoute(index, context, currentTheme, onThemeChanged, box);
    },
  );
}

void selectRoute(int index, BuildContext context, ThemeMode currentTheme,
    Function(ThemeMode) onThemeChanged, Box box) {
  switch (index) {
    case 0:
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => History(
                    currentTheme: currentTheme,
                    onThemeChanged: onThemeChanged,
                    box: box,
                  )));
      break;
    case 1:
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    currentTheme: currentTheme,
                    onThemeChanged: onThemeChanged,
                    box: box,
                  )));
      break;

    case 2:
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SettingsScreen(
                  currentTheme: currentTheme,
                  onThemeChanged: onThemeChanged,
                  box: box)));
      break;
  }
}
