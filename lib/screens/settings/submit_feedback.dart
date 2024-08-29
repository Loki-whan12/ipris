import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../services/backen_services.dart';

class SubmitFeedback extends StatefulWidget {
  final Box box;
  const SubmitFeedback({super.key, required this.box});

  @override
  State<SubmitFeedback> createState() => SubmitFeedbackState();
}

class SubmitFeedbackState extends State<SubmitFeedback> {
  String _feedbackType = 'Bug Report';
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  int _rating = 0;
  bool _isSaving = false;

  void _showSaveConfirmationDialog() {
    // Check if all fields are filled
    if (_subjectController.text.isEmpty ||
        _messageController.text.isEmpty ||
        _rating == 0) {
      _showErrorDialog(
          'Please fill in all fields and provide a rating before submitting.');
      return; // Exit the function if fields are not filled
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Review'),
          content:
              const Text('Are you sure you want to send the following review?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _saveReview();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
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

  void _saveReview() async {
    setState(() {
      _isSaving = true;
    });

    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    var username = updateAppProps['userInfo']['username'].toString();

    try {
      String comment = "${_subjectController.text}\n${_messageController.text}";
      Map reviewInfo = {
        "comment": comment,
        "rate": _rating,
        "username": username,
      };
      final response = await MyBackendService().addReviewDatabase(reviewInfo);
      if (response is Map &&
          response['message'] == "Comment created successfully") {
        setState(() {
          _isSaving = false;
        });
        _showSaveSuccessDialog();
      } else {
        setState(() {
          _isSaving = false;
        });
        _showErrorDialog(
            "An Error occurred\nYou can try to upload the review again\nBear with us as we work to resolve it");
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorDialog(
          "An error has occurred\nDo not worry the issue is from our side!\nWe are resolving it, bear with us...");
    }
  }

  void clearEnteries() {
    _subjectController.clear();
    _messageController.clear();
  }

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Review Saved'),
          content: const Text(
              'Your review has been uploaded!\nOur team would look at it and see how best we can help you.'),
          actions: [
            TextButton(
              onPressed: () {
                clearEnteries();
                Navigator.of(context).pop();
                // Stay on the current page
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
      appBar: AppBar(
        title: const Text('Submit Feedback'),
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
                'Feedback Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: const Text('Bug Report'),
                leading: Radio<String>(
                  value: 'Bug Report',
                  groupValue: _feedbackType,
                  onChanged: (value) {
                    setState(() {
                      _feedbackType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Feature Request'),
                leading: Radio<String>(
                  value: 'Feature Request',
                  groupValue: _feedbackType,
                  onChanged: (value) {
                    setState(() {
                      _feedbackType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('General Feedback'),
                leading: Radio<String>(
                  value: 'General Feedback',
                  groupValue: _feedbackType,
                  onChanged: (value) {
                    setState(() {
                      _feedbackType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter subject',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Message',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your message',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Rating',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                    ),
                    color: Colors.amber,
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (_isSaving)
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _showSaveConfirmationDialog,
                          child: const Text('Send'),
                        ),
                  (_isSaving)
                      ? const Text("")
                      : ElevatedButton(
                          onPressed: () {
                            // Handle cancel button press
                            clearEnteries();
                            setState(() {
                              _rating = 0; // Reset rating
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // Background color
                          ),
                          child: const Text('Cancel'),
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
