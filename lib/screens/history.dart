import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../componenets/bottom_nav.dart';
import '../componenets/drawer.dart';
import '../componenets/header.dart';
import '../componenets/utils.dart';
import '../services/backen_services.dart';
import 'scan/results.dart';

class History extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const History(
      {super.key,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String title = "History";
  String info = "Discover all plants you've scanned or uploaded!";
  List plants = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    try {
      var box = widget.box;
      Map updateAppProps = box.get("appProps");
      var username = updateAppProps['userInfo']['username'].toString();

      final response = await MyBackendService().fetchPlants(username);

      if (response is Map && response['message'] == "No plant found") {
        setState(() {
          loading = false;
        });
        return;
      }

      setState(() {
        plants = response;
        for (int i = 0; i < plants.length; i++) {
          var plantInfo = plants[i]['plant_info'];
          if (plantInfo is String) {
            try {
              plants[i]['plant_info'] =
                  jsonDecode(plantInfo.replaceAll("`", "\""));
            } catch (e) {
              print('Error decoding plant_info JSON string: $e');
            }
          }
        }
        loading = false;
      });
    } catch (e) {
      // Handle any errors that might occur during the fetch or parsing
      print('Error fetching plants: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<Uint8List> _loadImage(String base64String) async {
    return base64Decode(base64String);
  }

  Uint8List convertImage(String base64String) {
    return base64Decode(base64String);
  }

  String getPlantImageString(int index) {
    return plants[index]['image_data'].toString();
  }

  String getPlantCommonName(int index) {
    return plants[index]['plant_info']['result']['classification']
                ['suggestions'][0]['details']?['common_names']?[0]
            ?.toString() ??
        getPlantScientificName(index);
  }

  String getPlantScientificName(int index) {
    return plants[index]['plant_info']['result']['classification']
            ['suggestions'][0]['name']
        .toString();
  }

  String getPlantIndex(int index) {
    return plants[index]['id'].toString();
  }

  dynamic getPlantInfo(index) {
    return plants[index]['plant_info'];
  }

  dynamic getPlantUses(index) {
    return plants[index]['plant_uses'];
  }

  Future<void> _deletePlant(int index) async {
    try {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Deleting...'),
              ],
            ),
          );
        },
      );

      // Call the delete method
      final response =
          await MyBackendService().deletePlant(getPlantIndex(index));

      // Close the progress dialog
      Navigator.of(context).pop();

      // Check the response
      if (response is Map &&
          response['message'] == 'Plant deleted successfully') {
        // Update the UI
        setState(() {
          plants.removeAt(index);
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('The image has been deleted.'),
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
      } else {
        // Show error dialog if the response is not as expected
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content:
                  const Text('Failed to delete the image. Please try again.'),
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
    } catch (e) {
      // Close the progress dialog if there's an error
      Navigator.of(context).pop();

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Error deleting the image: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScreenText(pageName: title),
      ),
      drawer: MyDrawer(
        box: widget.box,
        currentDrawerItem: 1,
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            myHeader(context, info),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (plants.isEmpty)
              const Text(
                  "Sorry you haven't saved any images to the database yet!")
            else
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Uint8List>(
                              future: _loadImage(getPlantImageString(index)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Icon(Icons.error);
                                } else {
                                  return Image.memory(
                                    snapshot.data!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plant Name: ${getPlantCommonName(index)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Scientific Name: ${getPlantScientificName(index)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      var imageBytes = convertImage(
                                          getPlantImageString(index));
                                      var plantInfo = getPlantInfo(index);
                                      var plantUses = getPlantUses(index);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ResultsScreen(
                                            imageBytes: imageBytes,
                                            box: widget.box,
                                            currentTheme: widget.currentTheme,
                                            onThemeChanged:
                                                widget.onThemeChanged,
                                            showButtonsOfScanScreen: false,
                                            plantInfo: plantInfo,
                                            plantUses: plantUses,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Read More'),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Image'),
                                      content: const Text(
                                          'Are you sure you want to delete this image from the database?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context)
                                                .pop(); // Close the confirmation dialog
                                            await _deletePlant(index);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: myBottomNavBar(
          context, 0, widget.currentTheme, widget.onThemeChanged, widget.box),
    );
  }
}
