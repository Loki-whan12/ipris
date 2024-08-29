import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/backen_services.dart';
import '../login.dart';

class ChangePassword extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const ChangePassword(
      {super.key,
      required this.box,
      required this.currentTheme,
      required this.onThemeChanged});

  @override
  State<ChangePassword> createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool loading = false;
  String error = "";

  void displayError(String text) {
    setState(() {
      loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool validatePassword(String password) {
    // Validate password with regex: min 8 characters, 1 letter, 1 number, 1 special character
    final regex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> updatePassword() async {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    String databasePassword = updateAppProps['userInfo']['password'].toString();
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String username = updateAppProps['userInfo']['username'].toString();

    if (currentPassword.isEmpty) {
      displayError("Sorry, please enter your current password!");
    } else if (newPassword.isEmpty) {
      displayError("Sorry, please enter your new password!");
    } else if (confirmPassword.isEmpty) {
      displayError("Sorry, confirm new password field cannot be empty!");
    } else if (!validatePassword(newPassword)) {
      displayError(
          "New password must be at least 8 characters long and include a letter, number, and special character!");
    } else if (databasePassword != currentPassword) {
      setState(() {
        loading = false;
        error = "Sorry, your current password is incorrect!";
      });
    } else if (newPassword != confirmPassword) {
      setState(() {
        loading = false;
        error = "Sorry, your new passwords don't match!";
      });
    } else if (newPassword == currentPassword) {
      setState(() {
        loading = false;
        error =
            "Sorry, your new password is the same as the old one. Try again!";
      });
    } else {
      Map body = {
        "password": newPassword,
      };
      showWarningDialog(username, body);
    }
  }

  Future<dynamic> showWarningDialog(
      String username, Map<dynamic, dynamic> body) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Warning!"),
            content: const Text(
                "You will be redirected to the login screen once you change your email or password!"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      loading = true;
                      error = "";
                    });
                    MyBackendService()
                        .changePassowrd(username, body)
                        .whenComplete(() => logout());
                  },
                  child: const Text("Ok")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildPasswordField('Current Password', _currentPasswordController),
            _buildPasswordField('New Password', _newPasswordController),
            _buildPasswordField(
                'Confirm New Password', _confirmPasswordController),
            const SizedBox(height: 20),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        obscureText: true,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        (loading)
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = "";
                  });
                  updatePassword();
                },
                child: const Text('Save'),
              ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
