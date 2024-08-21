import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../componenets/drawer.dart';
import 'history.dart';
import 'login.dart';
import 'settings/change_email.dart';
import 'settings/change_password.dart';
import 'settings/select_theme.dart';

class Profile extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const Profile(
      {super.key,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");

    return Scaffold(
      drawer: MyDrawer(
        currentDrawerItem: 2,
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        box: widget.box,
      ),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        children: [
          _buildProfileHeader(),
          _buildSectionHeader('Personal Information'),

          _buildListItem('Email', updateAppProps['userInfo']['email'],
              onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeEmail(
                          box: widget.box,
                          currentTheme: widget.currentTheme,
                          onThemeChanged: widget.onThemeChanged,
                        )));
          }),
          // _buildListItem('Phone', '(233) 123-4567', onTap: () {
          //   // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   //     content: Text("Sorry this feature isn't available yet!")));
          // }),
          _buildSectionHeader('Account Settings'),
          _buildListItem('Change Password', '', onTap: () {
            // Handle change password
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangePassword(
                          box: widget.box,
                          currentTheme: widget.currentTheme,
                          onThemeChanged: widget.onThemeChanged,
                        )));
          }),
          _buildSectionHeader('Preferences'),
          _buildListItem('Theme', getTheme(), onTap: () {
            // Handle change theme
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectTheme(
                          currentTheme: widget.currentTheme,
                          onThemeChanged: widget.onThemeChanged,
                        )));
          }),
          _buildSectionHeader('Activity'),
          _buildListItem('Recent Identifications', '', onTap: () {
            // Handle view recent identifications
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => History(
                          currentTheme: widget.currentTheme,
                          onThemeChanged: widget.onThemeChanged,
                          box: widget.box,
                        )));
          }),
          _buildSectionHeader('Actions'),
          _buildListItem('Sign Out', '', onTap: () {
            logout();
            // Handle sign out
          }),
        ],
      ),
    );
  }

  String getTheme() {
    ThemeData themeData = Theme.of(context);
    if (themeData.brightness == Brightness.light) {
      return "Light";
    } else {
      return "Dark";
    }
  }

  ThemeMode getAppTheme() {
    ThemeData themeData = Theme.of(context);
    if (themeData.brightness == Brightness.light) {
      return ThemeMode.light;
    } else {
      return ThemeMode.dark;
    }
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

  Widget _buildProfileHeader() {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/imgs/plant-five.jpg'),
          ),
          const SizedBox(height: 10),
          Text(
            // 'User\'s Full Name',
            updateAppProps['userInfo']['name'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
