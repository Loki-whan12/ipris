import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../services/backen_services.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_theme.dart';
import 'login.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const PasswordRecoveryScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.box,
  });

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Focus nodes for text fields
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Variables to track focus state
  bool _usernameHasFocus = false;
  bool _nameHasFocus = false;
  bool _emailHasFocus = false;
  bool _newPasswordHasFocus = false;
  bool _confirmPasswordHasFocus = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addFocusListeners();
  }

  @override
  void dispose() {
    _disposeControllersAndFocusNodes();
    super.dispose();
  }

  // Add focus listeners to update focus state variables
  void _addFocusListeners() {
    _usernameFocusNode.addListener(() {
      setState(() {
        _usernameHasFocus = _usernameFocusNode.hasFocus;
      });
    });
    _nameFocusNode.addListener(() {
      setState(() {
        _nameHasFocus = _nameFocusNode.hasFocus;
      });
    });
    _emailFocusNode.addListener(() {
      setState(() {
        _emailHasFocus = _emailFocusNode.hasFocus;
      });
    });
    _newPasswordFocusNode.addListener(() {
      setState(() {
        _newPasswordHasFocus = _newPasswordFocusNode.hasFocus;
      });
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _confirmPasswordHasFocus = _confirmPasswordFocusNode.hasFocus;
      });
    });
  }

  // Dispose controllers and focus nodes
  void _disposeControllersAndFocusNodes() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocusNode.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
  }

  // Clear the text fields
  void _clearEntries() {
    _usernameController.clear();
    _nameController.clear();
    _emailController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  // Handle password change
  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data =
          await MyBackendService().getUserInfo(_usernameController.text);
      _responseHandler(data);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('An error occurred. Please try again.');
    }
  }

  // Show dialog when username is not found
  Future<void> _showOnUsernameNotFound() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid"),
          content: const Text("The username you provided is invalid."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Handle the response
  void _responseHandler(dynamic data) async {
    if (data == null) {
      setState(() {
        _isLoading = false;
      });
      _showOnUsernameNotFound();
    } else {
      if (_usernameController.text == data['username'] &&
          _nameController.text == data['name'] &&
          _emailController.text == data['email']) {
        final body = {"password": _confirmPasswordController.text};
        await MyBackendService().changePassowrd(data['username'], body);
        _showSuccessPopup();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage(
            'You have provided invalid details. Please try again.');
      }
    }
  }

  // Show error message dialog
  Future<void> _showErrorMessage(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text("$message\nPlease try again."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Show success popup dialog
  void _showSuccessPopup() {
    _clearEntries();
    setState(() {
      _isLoading = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Your password has been changed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const GradientBackground(
            children: [
              Text(
                "Recover Your Account",
                style: AppTheme.titleLarge,
              ),
              SizedBox(height: 6),
              Text("Recover your account if you can't login",
                  style: AppTheme.bodySmall),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextFormField(
                    focusNode: _usernameFocusNode,
                    controller: _usernameController,
                    labelText: 'Username',
                    hasFocus: _usernameHasFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    focusNode: _nameFocusNode,
                    controller: _nameController,
                    labelText: 'Full Name',
                    hasFocus: _nameHasFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    focusNode: _emailFocusNode,
                    controller: _emailController,
                    labelText: 'Email Address',
                    hasFocus: _emailHasFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    focusNode: _newPasswordFocusNode,
                    controller: _newPasswordController,
                    labelText: 'New Password',
                    hasFocus: _newPasswordHasFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new password';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField(
                    focusNode: _confirmPasswordFocusNode,
                    controller: _confirmPasswordController,
                    labelText: 'Confirm New Password',
                    hasFocus: _confirmPasswordHasFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  const SizedBox(height: 32.0),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _changePassword();
                            }
                          },
                          child: const Text('Recover Password'),
                        ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text("I already have an account? "),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(
                        currentTheme: widget.currentTheme,
                        onThemeChanged: widget.onThemeChanged,
                        box: widget.box,
                      ),
                    ),
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a text form field with common properties
  Widget _buildTextFormField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String labelText,
    required bool hasFocus,
    required String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      autovalidateMode: hasFocus
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: validator,
      obscureText: obscureText,
    );
  }
}
