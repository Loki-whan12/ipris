import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash.dart';
import 'values/app_props.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      // Initialize Hive for web
      Hive.init('');
    } else {
      // Initialize Hive for mobile
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }
    Box box = await Hive.openBox("iprisinfo");
    runApp(MyApp(box: box));
  } catch (e) {
    print('Error initializing Hive: $e');
  }
}

class MyApp extends StatefulWidget {
  final Box box;
  const MyApp({super.key, required this.box});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map appProps = AppProps().myAppProps;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    storeInitialData();
  }

  Future<void> _loadTheme() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      bool isDarkTheme = sharedPreferences.getBool('isDarkTheme') ?? false;
      setState(() {
        _themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
      });
    } catch (e) {
      print('Error loading theme from SharedPreferences: $e');
    }
  }

  Future<void> storeInitialData() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var box = widget.box;

      await box.put('appProps', appProps);
      if (!sharedPreferences.containsKey('firstRun')) {
        await box.put('firstRun', false);
        await box.put('isLoggedIn', false);
        sharedPreferences.setBool('firstRun', false);
        sharedPreferences.setBool('isLoggedIn', false);
        sharedPreferences.setBool('isDarkTheme', false);
      }
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
    }
  }

  void _changeTheme(ThemeMode themeMode) async {
    setState(() {
      _themeMode = themeMode;
    });

    // Save the theme mode to SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isDarkTheme = (themeMode == ThemeMode.dark);
    sharedPreferences.setBool('isDarkTheme', isDarkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPRIS',
      theme: ThemeData(
        brightness: Brightness.light,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(color: Colors.blue),
          unselectedLabelStyle: TextStyle(color: Colors.grey),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.lightGreen,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(color: Colors.green),
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: Splash(
        currentTheme: _themeMode,
        onThemeChanged: _changeTheme,
        box: widget.box,
      ),
    );
  }
}
