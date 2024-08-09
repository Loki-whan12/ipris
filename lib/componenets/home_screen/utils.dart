
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Padding titleForSubComponents(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
    ),
  );
}
