import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../componenets/spacers.dart';
import '../services/backen_services.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const RegisterPage(
      {super.key,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _fullNameHasFocus = false;
  bool _usernameHasFocus = false;
  bool _emailHasFocus = false;
  bool _passwordHasFocus = false;
  bool _confirmPasswordHasFocus = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    _fullNameFocusNode.addListener(() {
      setState(() {
        _fullNameHasFocus = _fullNameFocusNode.hasFocus;
      });
    });
    _usernameFocusNode.addListener(() {
      setState(() {
        _usernameHasFocus = _usernameFocusNode.hasFocus;
      });
    });
    _emailFocusNode.addListener(() {
      setState(() {
        _emailHasFocus = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordHasFocus = _passwordFocusNode.hasFocus;
      });
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _confirmPasswordHasFocus = _confirmPasswordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fullNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const GradientBackground(
              children: [
                Text(
                  AppStrings.register,
                  style: AppTheme.titleLarge,
                ),
                SizedBox(height: 6),
                Text(AppStrings.signInToYourAccount, style: AppTheme.bodySmall),
              ],
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: fullnameController,
                      focusNode: _fullNameFocusNode,
                      autovalidateMode: _fullNameHasFocus
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    myHeightSpacer(10),
                    TextFormField(
                      controller: usernameController,
                      focusNode: _usernameFocusNode,
                      autovalidateMode: _usernameHasFocus
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        } else if (value.length < 5) {
                          return "Please username canot be < 5 characters";
                        }
                        return null;
                      },
                    ),
                    myHeightSpacer(10),
                    TextFormField(
                      controller: emailController,
                      focusNode: _emailFocusNode,
                      autovalidateMode: _emailHasFocus
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Regex for email validation
                        String pattern =
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    myHeightSpacer(10),
                    TextFormField(
                      focusNode: _passwordFocusNode,
                      controller: passwordController,
                      autovalidateMode: _passwordHasFocus
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),
                    myHeightSpacer(10),
                    TextFormField(
                      focusNode: _confirmPasswordFocusNode,
                      controller: confirmPasswordController,
                      autovalidateMode: _confirmPasswordHasFocus
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: (loading)
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                // Validate returns true if the form is valid, otherwise false.
                                if (_formKey.currentState?.validate() == true) {
                                  // Process data.
                                  showWarningDialog();
                                }
                              },
                              child: const Text('Register'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text("I have an account already? "),
                  TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Login(
                                    currentTheme: widget.currentTheme,
                                    onThemeChanged: widget.onThemeChanged,
                                    box: widget.box,
                                  ))),
                      child: const Text("Login"))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showWarningDialog() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Warning!"),
          content: const Text(
              "You are about to create an account with us.\nSelect 'Yes' if you agree"
              " with our Terms of service and conditions!"),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Yes")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("No")),
          ],
        );
      },
    );

    if (shouldProceed == true) {
      setState(() {
        loading = true;
      });

      Map userInfo = {
        "username": usernameController.text,
        "name": fullnameController.text,
        "email": emailController.text,
        "password": confirmPasswordController.text
      };

      try {
        final value =
            await MyBackendService().addUserToBackendDatabase(userInfo);
        if (value is Map && value['message'] == "Username taken") {
          setState(() {
            loading = false;
          });
          await usernameTakenError();
        } else if (value is Map &&
            value['message'] == "User created successfully") {
          setState(() {
            loading = false;
          });
          await redirectToLoginScreen();
        }
      } catch (e) {
        // Handle error appropriately
        showErrorHasOccured();
        print('An error occurred: $e');
      } finally {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    }
  }

  Future<void> redirectToLoginScreen() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: const Text(
              "Your account has been created successfully!\nPress 'OK' to be redirected to the Login screen!"),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Login(
                                currentTheme: widget.currentTheme,
                                onThemeChanged: widget.onThemeChanged,
                                box: widget.box,
                              )));
                },
                child: const Text("OK")),
          ],
        );
      },
    );
  }

  Future<void> usernameTakenError() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(
              "Sorry the username '${usernameController.text}' has already been taken!\nPlease try again with a different username!"),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK")),
          ],
        );
      },
    );
  }

  Future<void> showErrorHasOccured() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Unknown Eror!"),
          content: const Text(
              "Sorry an unknown error has occured!\nPlease try again..."),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK")),
          ],
        );
      },
    );
  }
}
