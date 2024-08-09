import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'We respect your privacy and are committed to protecting your personal information.'),
              const Text(
                  'This Privacy Policy explains how we collect, use, and disclose your information.'),
              const SizedBox(height: 20),
              const Text('Information We Collect:'),
              const Text('- Photos you upload for plant identification.'),
              const Text('- Location data to improve identification accuracy.'),
              const Text('- Device information for app optimization.'),
              const SizedBox(height: 20),
              const Text('How We Use Your Information:'),
              const Text('- To provide plant identification services.'),
              const Text('- To improve our app and develop new features.'),
              const Text('- To respond to user inquiries and support requests.'),
              const SizedBox(height: 20),
              const Text('Data Sharing:'),
              const Text('- We do not sell your information to third parties.'),
              const Text(
                  '- We may share data with service providers for app functionality.'),
              const SizedBox(height: 20),
              const Text('Your Rights:'),
              const Text('- You have the right to access and correct your information.'),
              const Text('- You can request the deletion of your data.'),
              const SizedBox(height: 20),
              const Text('Contact Us:'),
              const Text('- For privacy-related inquiries, please contact us at privacy@ipris.com.'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Accept privacy policy
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
