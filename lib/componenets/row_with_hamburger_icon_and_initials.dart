import 'package:flutter/material.dart';

Padding rowWithHamburgerAndInitials(BuildContext context, String initials) {
  return Padding(
    padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          );
        }),
        CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 15, 23, 31),
          child: Text(
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        )
      ],
    ),
  );
}
