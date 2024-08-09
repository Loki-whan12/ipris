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

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void initState() {
    super.initState();
    storeInitialData();
  }

  Future<void> storeInitialData() async {
    try {
      print("Attempting to initialize SharedPreferences");
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      print("SharedPreferences initialized successfully");

      var box = widget.box;
      await box.put('appProps', appProps);
      if (!box.containsKey('firstRun')) {
        await box.put('firstRun', false);
        await box.put('isLoggedIn', false);
        sharedPreferences.setBool('firstRun', false);
        sharedPreferences.setBool('isLoggedIn', false);
        print("Done... with initializing");
      }
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
    }
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
