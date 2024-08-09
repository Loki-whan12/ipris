import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../screens/scan/scan_upload.dart';

FloatingActionButton floatingActionButtonForScanPage(BuildContext context,
    ThemeMode currentTheme, Function(ThemeMode) onThemeChanged, Box box) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ScanPage(
                    currentTheme: currentTheme,
                    onThemeChanged: onThemeChanged,
                    box: box,
                  )));
    },
    elevation: 10.0,
    foregroundColor: Colors.cyanAccent,
    backgroundColor: const Color.fromARGB(202, 5, 33, 56),
    child: const Icon(Icons.camera_alt_sharp),
  );
}
