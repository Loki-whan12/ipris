import 'package:flutter/material.dart';

class ScreenText extends StatelessWidget {
  const ScreenText({
    super.key,
    required String pageName,
  }) : _pageName = pageName;

  final String _pageName;

  @override
  Widget build(BuildContext context) {
    return Text(
      _pageName,
      style: const TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required String initials,
  }) : _initials = initials;

  final String _initials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: CircleAvatar(
        backgroundColor: const Color.fromARGB(255, 15, 23, 31),
        child: Text(
          _initials,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
