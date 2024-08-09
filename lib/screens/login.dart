import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:ipris/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../resources/resources.dart';
import '../services/backen_services.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';
import 'recover_password.dart';
import 'register.dart';

class Login extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;

  const Login({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.box,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool loading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> showErrorMessage(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text("$message\nPlease try again..."),
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

  Future<void> showOnUsernameNotFound() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Info"),
          content: const Text(
              "Your username is invalid or wrong\nIf it is that you don't have"
              " an account.\nSelect 'Proceed' to be redirected to the register"
              " page\nTo create an account.\nOr you can try again if you"
              " misspleled your username..."),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(
                        currentTheme: widget.currentTheme,
                        onThemeChanged: widget.onThemeChanged,
                        box: widget.box,
                      ),
                    ),
                  );
                },
                child: const Text("Proceed")),
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

  void proceedWithLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      MyBackendService()
          .getUserInfo(usernameController.text)
          .then((data) => loginResponseHandler(data))
          .catchError((error) {
        setState(() {
          loading = false;
          showErrorMessage('An error occurred. Please try again.');
        });
      });
    }
  }

  void loginResponseHandler(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data == null) {
      setState(() {
        loading = false;
        showOnUsernameNotFound();
      });
    } else {
      Map updateAppProps = widget.box.get('appProps', defaultValue: {});
      updateAppProps['userInfo'] = data;
      prefs.setString('userInfo', jsonEncode(data));

      if (passwordController.text == data['password']) {
        updateAppProps['isLoggedIn'] = true;
        await widget.box.put('appProps', updateAppProps);
        await widget.box.put('isLoggedIn', true);
        prefs.setBool('isLoggedIn', true);

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
        setState(() {
          loading = false;
          showErrorMessage('Please check your password and try again...');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const GradientBackground(
            children: [
              Text(
                AppStrings.signInToYourNAccount,
                style: AppTheme.titleLarge,
              ),
              SizedBox(height: 6),
              Text(AppStrings.signInToYourAccount, style: AppTheme.bodySmall),
            ],
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    focusNode: _usernameFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.pleaseEnterUsername;
                      } else if (value.length < 5) {
                        return "Please username canot be < 5 characters";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      _usernameFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    autovalidateMode: _usernameFocusNode.hasFocus
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.password,
                      hintText: 'Enter your password',
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    focusNode: _passwordFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.pleaseEnterPassword;
                      } else if (value.length < 8) {
                        return "Please password canot be < 8 characters";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      _passwordFocusNode.unfocus();
                    },
                    autovalidateMode: _passwordFocusNode.hasFocus
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PasswordRecoveryScreen(
                                      currentTheme: widget.currentTheme,
                                      onThemeChanged: widget.onThemeChanged,
                                      box: widget.box,
                                    ))),
                        child: const Text(AppStrings.forgotPassword),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  (loading)
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: proceedWithLogin,
                          child: const Text(AppStrings.login),
                        ),
                  const SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {},
                  //         icon: SvgPicture.asset(Vectors.google, width: 14),
                  //         label: const Text(
                  //           AppStrings.google,
                  //           style: TextStyle(color: Colors.black),
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 20),
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {},
                  //         icon: SvgPicture.asset(Vectors.facebook, width: 14),
                  //         label: const Text(
                  //           AppStrings.facebook,
                  //           style: TextStyle(color: Colors.black),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.doNotHaveAnAccount,
                        style: AppTheme.bodySmall.copyWith(color: Colors.black),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(
                                currentTheme: widget.currentTheme,
                                onThemeChanged: widget.onThemeChanged,
                                box: widget.box,
                              ),
                            ),
                          );
                        },
                        child: const Text(AppStrings.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
