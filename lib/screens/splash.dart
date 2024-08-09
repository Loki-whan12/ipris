import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;

  const Splash({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.box,
  });

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateToNextScreen();
    });
  }

  void navigateToNextScreen() async {
    print("Navigating to next screen...");

    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var box = widget.box;
      print("Box retrieved: $box");

      Map? updateAppProps = box.get("appProps");
      updateAppProps ??= {};
      updateAppProps['firstRun'] = true;
      var isLoggedIn = box.get('isLoggedIn');
      print("isLoggedIn from box: $isLoggedIn");

      var _isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
      print("isLoggedIn from SharedPreferences: $_isLoggedIn");

      bool val = _isLoggedIn;

      await box.put('appProps', updateAppProps);
      await sharedPreferences.setBool('firstRun', true);
      print("Data saved, delaying...");

      await Future.delayed(const Duration(milliseconds: 1500));
      print("Delay completed");

      // Proceed with navigation
      if (val) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              currentTheme: widget.currentTheme,
              onThemeChanged: widget.onThemeChanged,
              box: widget.box,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(
              currentTheme: widget.currentTheme,
              onThemeChanged: widget.onThemeChanged,
              box: widget.box,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      // Handle the error, possibly show an error dialog or retry logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 400,
              child: Image.asset('assets/imgs/plant-one.jpg'),
            ),
            const Text(
              "IPRIS",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
