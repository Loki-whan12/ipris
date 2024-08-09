import 'package:flutter/material.dart';

class EmailSupport extends StatefulWidget {
  const EmailSupport({super.key});

  @override
  State<EmailSupport> createState() => _EmailSupportState();
}

class _EmailSupportState extends State<EmailSupport> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _sendEmail() {
    // ignore: unused_local_variable
    final String subject = _subjectController.text;
    // ignore: unused_local_variable
    final String message = _messageController.text;

    // Handle the email sending logic here

    // Clear the fields after sending the email
    _subjectController.clear();
    _messageController.clear();

    // Show a confirmation message or navigate back
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Email sent successfully!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Subject', _subjectController),
            _buildMultilineTextField('Message', _messageController),
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildMultilineTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: 8,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _sendEmail,
          child: const Text('Send'),
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
