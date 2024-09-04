import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../services/backen_services.dart';
import 'scan/results.dart';
import 'search_result_page.dart';

class SearchReults extends StatefulWidget {
  final String plantName;
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const SearchReults({
    super.key,
    required this.plantName,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.box,
  });

  @override
  State<SearchReults> createState() => _SearchReultsState();
}

class _SearchReultsState extends State<SearchReults> {
  bool isLoading = false;

  Future<List<dynamic>> _fetchSearchResults(String plantName) async {
    try {
      final response = await MyBackendService().getPlantsByName(plantName);

      if (response['entities'] != null && response['entities'] is List) {
        final validEntities = response['entities'].where((plant) {
          try {
            final String? base64Image = plant['thumbnail'];
            if (base64Image != null && base64Image.isNotEmpty) {
              base64Decode(base64Image);
              return true;
            }
            return false;
          } catch (e) {
            print('Invalid image detected, excluding from results.');
            return false;
          }
        }).toList();

        return validEntities;
      } else {
        print('Error: Expected "entities" to be a list.');
        return [];
      }
    } catch (e) {
      print('Error fetching search results: $e');
      return [];
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> handleImage(Uint8List bytes, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await MyBackendService()
          .identifyPlantAndGetUses(bytes, "filename.jpg");

      if (response is Map &&
          response.containsKey('message') &&
          response['message'] == 'success') {
        if (response['plant_info']['result']['is_plant']['binary'] == false) {
          setState(() {
            isLoading = false;
            _showErrorDialog(context,
                "The image does not contain a plant. Please try again with a different image.");
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print(response['plant_uses']);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                imageBytes: bytes,
                box: widget.box,
                currentTheme: widget.currentTheme,
                onThemeChanged: widget.onThemeChanged,
                showButtonsOfScanScreen: true,
                plantInfo: response['plant_info'],
                plantUses: response['plant_uses']?['plant_uses'] ?? {},
              ),
            ),
          );
        }
      } else if (response is Map && response.containsKey('error')) {
        setState(() {
          isLoading = false;
          _showErrorDialog(context, response['error']);
        });
      } else {
        setState(() {
          isLoading = false;
          _showErrorSnackbar(context, "Unsupported image format detected");
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
        _showErrorSnackbar(context, "Failed to pick image: ${e.message}");
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _showErrorSnackbar(context, "Error occurred: ${e.toString()}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "${widget.plantName}"'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
              future: _fetchSearchResults(widget.plantName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error fetching search results: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No valid results found'));
                } else {
                  final results = snapshot.data!;
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final plant = results[index];
                      final String plantName =
                          (plant['matched_in'] ?? 'Unknown Plant')
                              .toString()
                              .toUpperCase();
                      final String entityName =
                          (plant['entity_name'] ?? 'No entity name found')
                              .toString();
                      final String base64Image = plant['thumbnail'] ?? '';

                      return ListTile(
                        leading: FutureBuilder<Uint8List?>(
                          future: _convertBase64ToBytes(base64Image),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              );
                            } else if (imageSnapshot.hasError ||
                                !imageSnapshot.hasData ||
                                imageSnapshot.data == null) {
                              return const Icon(Icons.image_not_supported,
                                  size: 50);
                            } else {
                              return Image.memory(
                                imageSnapshot.data!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported,
                                      size: 50);
                                },
                              );
                            }
                          },
                        ),
                        title: Text(
                          plantName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          entityName,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        onTap: () {
                          print(plant['access_token']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultPage(
                                accessToken: plant['access_token'],
                                base64Image: base64Image,
                              ),
                            ),
                          );
                          // handleImage(base64Decode(base64Image), context);
                        },
                      );
                    },
                  );
                }
              },
            ),
    );
  }

  // Convert base64 string to bytes with error handling
  Future<Uint8List?> _convertBase64ToBytes(String base64String) async {
    try {
      if (base64String.isEmpty) return null;
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 string: $e');
      return null;
    }
  }

  Uint8List convertImage(String base64String) {
    return base64Decode(base64String);
  }
}
