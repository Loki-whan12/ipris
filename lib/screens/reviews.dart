import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../componenets/drawer.dart';
import '../services/backen_services.dart';

class ReviewScreen extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const ReviewScreen(
      {super.key,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      drawer: MyDrawer(
        currentDrawerItem: 4,
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        box: widget.box,
      ),
      body: FutureBuilder(
        future: MyBackendService().fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading reviews'));
          } else {
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Center(child: Text('No reviews found'));
            }
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final int ratings =
                    int.tryParse(review['rate'].toString()) ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.reviews, color: Colors.blue, size: 40),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['username'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                review['comment'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < ratings
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
