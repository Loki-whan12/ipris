import 'package:flutter/material.dart';

class SelectTheme extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  const SelectTheme(
      {super.key, required this.currentTheme, required this.onThemeChanged});

  @override
  State<SelectTheme> createState() => _SelectThemeState();
}

class _SelectThemeState extends State<SelectTheme> {
  late ThemeMode _selectedTheme;

  @override
  void didUpdateWidget(covariant SelectTheme oldWidget) {
    if (widget.currentTheme != oldWidget.currentTheme) {
      setState(() {
        _selectedTheme = widget.currentTheme;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    print(widget.currentTheme);
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Theme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTheme = ThemeMode.light;
                    widget.onThemeChanged(_selectedTheme);
                    Navigator.pop(context);
                  });
                },
                child: const Text('Light Mode'),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTheme = ThemeMode.dark;
                    widget.onThemeChanged(_selectedTheme);
                    Navigator.pop(context);
                  });
                },
                child: const Text('Dark Mode'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.onThemeChanged(_selectedTheme);
              Navigator.pop(context);
            });
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
