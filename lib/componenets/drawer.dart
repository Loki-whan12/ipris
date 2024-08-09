import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/history.dart';
import '../screens/home_screen.dart';
import '../screens/login.dart';
import '../screens/profile.dart';
import '../screens/reviews.dart';
import '../screens/settings.dart';
import '../screens/about_us.dart';

class MyDrawer extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final int currentDrawerItem;
  final Box box;
  const MyDrawer(
      {super.key,
      required this.currentDrawerItem,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool currentItem(int pageId) {
    return (pageId == widget.currentDrawerItem);
  }

  void selectRoute(int routeId, BuildContext context) {
    List drawerRoutes = [
      HomeScreen(
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        box: widget.box,
      ),
      History(
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        box: widget.box,
      ),
      Profile(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
          box: widget.box),
      SettingsScreen(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
          box: widget.box),
      ReviewScreen(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
          box: widget.box),
      AboutUs(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
          box: widget.box),
    ];

    (routeId == widget.currentDrawerItem)
        ? Navigator.pop(context)
        : Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => drawerRoutes[routeId]),
    );
  }

  String getUsername() {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    return updateAppProps['userInfo']['name'];
  }

  String getEmail() {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    return updateAppProps['userInfo']['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(getUsername()),
            accountEmail: Text(getEmail()),
            currentAccountPicture: const CircleAvatar(
              child: Icon(
                Icons.account_circle_rounded,
                size: 70.0,
              ),
            ),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/imgs/plant-six.jpg'),
                    fit: BoxFit.cover)),
          ),
          ListTile(
            selected: currentItem(0),
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => selectRoute(0, context),
          ),
          ListTile(
            selected: currentItem(1),
            leading: const Icon(Icons.history),
            title: const Text("Histroy"),
            onTap: () => selectRoute(1, context),
          ),
          ListTile(
            selected: currentItem(2),
            leading: const Icon(Icons.account_circle),
            title: const Text("Profile"),
            onTap: () => selectRoute(2, context),
          ),
          ListTile(
            selected: currentItem(3),
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => selectRoute(3, context),
          ),
          ListTile(
            selected: currentItem(4),
            leading: const Icon(Icons.rate_review),
            title: const Text("Reviews"),
            onTap: () => selectRoute(4, context),
          ),
          const Divider(),
          ListTile(
            selected: currentItem(5),
            leading: const Icon(Icons.all_inbox_outlined),
            title: const Text("About Us"),
            onTap: () => selectRoute(5, context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    var box = widget.box;

    Map updateAppProps = box.get("appProps");
    updateAppProps['isLoggedIn'] = false;
    await widget.box.put('isLoggedIn', false);
    prefs.setBool('isLoggedIn', false);

    await box.put('appProps', updateAppProps).whenComplete(() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Login(
                    currentTheme: widget.currentTheme,
                    onThemeChanged: widget.onThemeChanged,
                    box: widget.box,
                  )));
    });
  }
}
