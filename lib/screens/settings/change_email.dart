import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ipris/services/backen_services.dart';
import '../login.dart';

class ChangeEmail extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const ChangeEmail({
    super.key,
    required this.box,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _newEmailFocusNode = FocusNode();
  final FocusNode _confirmEmailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

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
    _currentEmail = updateAppProps['userInfo']['email'].toString();
  }

  void displayError(String text) {
    setState(() {
      loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> updateEmail() async {
    if (_formKey.currentState!.validate()) {
      var box = widget.box;
      Map updateAppProps = box.get("appProps");
      String databasePassword = updateAppProps['userInfo']['password'].toString();
      String databaseEmail = updateAppProps['userInfo']['email'].toString();
      String newEmail = _newEmailController.text;
      String userPassword = _passwordController.text;
      String username = updateAppProps['userInfo']['username'].toString();

      if (databasePassword != userPassword) {
        setState(() {
          loading = false;
          error = "Sorry, Your password you entered is incorrect!";
        });
      } else if (databaseEmail == newEmail) {
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

  Future<dynamic> showWarningDialog(String username, Map<dynamic, dynamic> body) {
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
              child: const Text("Ok"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
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

  @override
  void dispose() {
    _newEmailController.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    _newEmailFocusNode.dispose();
    _confirmEmailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildReadOnlyField('Current Email', _currentEmail),
              _buildEmailField('New Email', _newEmailController, _newEmailFocusNode),
              _buildEmailField('Confirm New Email', _confirmEmailController, _confirmEmailFocusNode),
              _buildPasswordField('Password', _passwordController, _passwordFocusNode),
              const SizedBox(height: 20),
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
              _buildActions(),
            ],
          ),
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

  Widget _buildEmailField(String label, TextEditingController controller, FocusNode focusNode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an email';
          } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
        onFieldSubmitted: (_) {
          focusNode.unfocus();
          FocusScope.of(context).requestFocus(_confirmEmailFocusNode);
        },
        autovalidateMode: focusNode.hasFocus
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, FocusNode focusNode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          } else if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
            return 'Password must include letters, numbers, and special characters';
          }
          return null;
        },
        onFieldSubmitted: (_) {
          focusNode.unfocus();
        },
        autovalidateMode: focusNode.hasFocus
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
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
