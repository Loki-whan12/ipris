import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../componenets/drawer.dart';
import 'settings/privacy_policy.dart';
import 'settings/terms_of_service.dart';

class AboutUs extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const AboutUs(
      {super.key,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        currentDrawerItem: 5,
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        box: widget.box,
      ),
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionHeader('Our Mission'),
            _buildTextContent(
                'Our mission is to provide users with accurate and reliable plant identification through advanced technology and user-friendly design. We aim to foster a deeper appreciation and understanding of the natural world.'),
            _buildSectionHeader('Our Team'),
            _buildTextContent(
                'We are a diverse team of botanists, engineers, and designers dedicated to making plant identification accessible to everyone. Our combined expertise ensures that our app is both scientifically accurate and easy to use.'),
            _buildSectionHeader('Our Story'),
            _buildTextContent(
                'Our journey began with a simple question: How can we make plant identification easier for everyone? From this question, our app was born. Since then, we have been committed to continuous improvement and innovation.'),
            _buildSectionHeader('Contact Us'),
            _buildContactInfo(
                email: 'support@yourapp.com',
                phone: '(123) 456-7890',
                address: '123 Plant St, Botanical City, Country'),
            _buildSectionHeader('Follow Us'),
            _buildSocialMediaLinks(),
            _buildSectionHeader('Legal'),
            _buildLegalLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContactInfo(
      {required String email, required String phone, required String address}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email: $email',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Phone: $phone',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Address: $address',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    // Placeholder for social media links, customize as needed
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.facebook),
            onPressed: () {
              // Handle Facebook link
            },
          ),
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
              // Handle Twitter link
            },
          ),
          IconButton(
            icon: const Icon(Icons.facebook),
            onPressed: () {
              // Handle Instagram link
            },
          ),
          IconButton(
            icon: const Icon(Icons.snapchat),
            onPressed: () {
              // Handle LinkedIn link
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TermsOfService())),
            child: const Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicy())),
            child: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
