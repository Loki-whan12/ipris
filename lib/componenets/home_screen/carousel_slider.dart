import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../gradient_card.dart';

Text plantscientificNameText(String plantScientificName) {
  return Text(
    plantScientificName,
    style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        color: Colors.black87),
  );
}

Text commonName(String plantName) {
  return Text(
    plantName,
    style: const TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w700, color: Colors.black87),
  );
}

List<Widget> cardItems = [
  const GradientCard(
    gradientColors: [Colors.blue, Colors.blueAccent],
    title: 'Home',
    subtitle: 'This is the Home screen, where you can find the main content.',
  ),
  const GradientCard(
    gradientColors: [Colors.green, Colors.greenAccent],
    title: 'History',
    subtitle: 'View your scan history and previous identifications.',
  ),
  const GradientCard(
    gradientColors: [Colors.orange, Colors.orangeAccent],
    title: 'Profile',
    subtitle: 'Manage your profile settings and information.',
  ),
  const GradientCard(
    gradientColors: [Colors.purple, Colors.purpleAccent],
    title: 'Settings',
    subtitle: 'Adjust the app settings to your preference.',
  ),
  const GradientCard(
    gradientColors: [Colors.red, Colors.redAccent],
    title: 'Review',
    subtitle: 'Review and provide feedback for the app.',
  ),
  const GradientCard(
    gradientColors: [Colors.teal, Colors.tealAccent],
    title: 'About Us',
    subtitle: 'Learn more about the app and the team behind it.',
  ),
];

CarouselSlider myCarouselSlider() {
  return CarouselSlider(
      items: cardItems,
      options: CarouselOptions(
        height: 250,
        aspectRatio: 16 / 9,
        viewportFraction: 0.72,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
        scrollDirection: Axis.horizontal,
      ));
}
