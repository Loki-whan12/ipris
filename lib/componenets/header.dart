import 'package:flutter/material.dart';

SizedBox myHeader(BuildContext context, String info) {
  return SizedBox(
    height: 30,
    width: MediaQuery.sizeOf(context).width,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Row(
            children: [
              Text(
                info,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Text welcomeText(String text1) {
  return Text(
    text1,
    style: const TextStyle(
      fontSize: 22.5,
      fontWeight: FontWeight.w700,
    ),
  );
}

Text infoText(String text1) {
  return Text(
    text1,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
  );
}
