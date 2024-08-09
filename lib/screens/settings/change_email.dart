import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ipris/services/backen_services.dart';

import '../login.dart';

class ChangeEmail extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const ChangeEmail(
      {super.key,
      required this.box,
      required this.currentTheme,
      required this.onThemeChanged});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final String _currentEmail;
  bool loading = false;
  String error = "";

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    // var userEmail = updateAppProps['userInfo']
    print(updateAppProps);
    _currentEmail = updateAppProps['userInfo']['email'].toString();
  }

  void displayError(String text) {
    setState(() {
      loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> updateEmail() async {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    String databasePassword = updateAppProps['userInfo']['password'].toString();
    String databaseEmail = updateAppProps['userInfo']['email'].toString();
    String newEmail = _newEmailController.text;
    String confrimEmail = _confirmEmailController.text;
    String userPassword = _passwordController.text;
    String username = updateAppProps['userInfo']['username'].toString();

    if (_newEmailController.text.isEmpty) {
      displayError("Sorry, please enter an email!");
    } else if (_confirmEmailController.text.isEmpty) {
      displayError("Sorry, please enter an email to confirm your email!");
    } else if (_passwordController.text.isEmpty) {
      displayError("Sorry, password field cannot be empty!");
    } else {
      if (newEmail != confrimEmail) {
        setState(() {
          loading = false;
          error = "Sorry, emails don't match";
        });
      } else {
        if (databasePassword != userPassword) {
          setState(() {
            loading = false;
            error = "Sorry, Your password you entered is incorrect!";
          });
        } else {
          if (databaseEmail == newEmail) {
            setState(() {
              loading = false;
              error = "Sorry, your new email is the same as the old one!";
            });
          } else {
            Map body = {
              "email": newEmail,
            };
            showWarningDialog(username, body);
          }
        }
      }
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
                "You would be redirected to the login screen once you change your email or password!"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      loading = true;
                      error = "";
                    });
                    MyBackendService()
                        .changeEmail(username, body)
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
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    updateAppProps['isLoggedIn'] = false;
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
        title: const Text('Change Email'),
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
            _buildReadOnlyField('Current Email', _currentEmail),
            _buildTextField('New Email', _newEmailController),
            _buildTextField('Confirm New Email', _confirmEmailController),
            _buildPasswordField('Password', _passwordController),
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

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
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
                  updateEmail();
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
