import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../componenets/drawer.dart';
import 'settings/change_email.dart';
import 'settings/change_password.dart';
import 'profile.dart';
import 'settings/email_support.dart';
import 'settings/privacy_policy.dart';
import 'settings/select_theme.dart';
import 'settings/submit_feedback.dart';
import 'settings/terms_of_service.dart';
import 'settings/version_number.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const SettingsScreen(
      {super.key,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final bool _twoFactorAuth;
  late final bool _generalNotifications;
  late final bool _identificationResults;
  late final bool _offlineMode;
  late final bool _syncWithCloud;
  late final bool _dataSharing;
  late final bool _usageStatistics;
  late final bool _cameraAccess;
  late final bool _locationAccess;
  var settingsProp;

  @override
  void initState() {
    getSettingsProps().then((value) => setState(() {
          settingsProp = value['settingsProps'];
          print(settingsProp);
          setProps();
        }));
    super.initState();
  }

  void setProps() {
    _twoFactorAuth = settingsProp['twoFactorAuth'];
    _generalNotifications = settingsProp['generalNotifications'];
    _identificationResults = settingsProp['identificationResults'];
    _offlineMode = settingsProp['offlineMode'];
    _syncWithCloud = settingsProp['syncWithCloud'];
    _dataSharing = settingsProp['dataSharing'];
    _usageStatistics = settingsProp['usageStatistics'];
    _cameraAccess = settingsProp['cameraAccess'];
    _locationAccess = settingsProp['locationAccess'];
  }

  Future<dynamic> getSettingsProps() async {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    return updateAppProps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        currentDrawerItem: 3,
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        box: widget.box,
      ),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: (settingsProp == null)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader('Account'),
                _buildListItem('View Profile', onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(
                                currentTheme: widget.currentTheme,
                                onThemeChanged: widget.onThemeChanged,
                                box: widget.box,
                              )));
                }),
                _buildListItem('Change Email', onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeEmail(
                                box: widget.box,
                                currentTheme: widget.currentTheme,
                                onThemeChanged: widget.onThemeChanged,
                              )));
                }),
                _buildListItem('Change Password', onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePassword(
                                box: widget.box,
                                currentTheme: widget.currentTheme,
                                onThemeChanged: widget.onThemeChanged,
                              )));
                }),
                // _buildToggleItem('Two-Factor Authentication', _twoFactorAuth,
                //     (value) {
                //   setState(() {
                //     _twoFactorAuth = value;
                //   });
                // }),
                _buildSectionHeader('App Preferences'),
                _buildToggleItem('General Notifications', _generalNotifications,
                    (value) {
                  setState(() {
                    _generalNotifications = value;
                  });
                }),
                _buildToggleItem(
                    'Identification Results', _identificationResults, (value) {
                  setState(() {
                    _identificationResults = value;
                  });
                }),
                _buildListItem('Theme',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectTheme(
                                  currentTheme: widget.currentTheme,
                                  onThemeChanged: widget.onThemeChanged,
                                )))),
                _buildSectionHeader('Plant Database'),
                _buildToggleItem('Enable Offline Access', _offlineMode,
                    (value) {
                  setState(() {
                    _offlineMode = value;
                  });
                }),
                _buildToggleItem('Sync with Cloud', _syncWithCloud, (value) {
                  setState(() {
                    _syncWithCloud = value;
                  });
                }),
                _buildSectionHeader('Privacy and Security'),
                _buildToggleItem('Data Sharing', _dataSharing, (value) {
                  setState(() {
                    _dataSharing = value;
                  });
                }),
                _buildToggleItem('Usage Statistics', _usageStatistics, (value) {
                  setState(() {
                    _usageStatistics = value;
                  });
                }),
                _buildToggleItem('Camera Access', _cameraAccess, (value) {
                  setState(() {
                    _cameraAccess = value;
                  });
                }),
                _buildToggleItem('Location Access', _locationAccess, (value) {
                  setState(() {
                    _locationAccess = value;
                  });
                }),
                _buildSectionHeader('Support and Feedback'),
                _buildListItem('Email Support',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmailSupport()))),
                _buildListItem('Submit Feedback',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubmitFeedback(
                                  box: widget.box,
                                )))),
                _buildSectionHeader('About'),
                _buildListItem('Version Number',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VersionNumber()))),
                _buildListItem('Terms of Service',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TermsOfService()))),
                _buildListItem('Privacy Policy',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrivacyPolicy()))),
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
        ),
      ),
    );
  }

  Widget _buildListItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: null,
    );
  }
}
