import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../services/backen_services.dart';
import '../../services/plant_api_service.dart';
import 'scan_upload.dart';

class ResultsScreen extends StatefulWidget {
  final bool showButtonsOfScanScreen;
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Map<dynamic, dynamic> plantInfo;
  final Map<dynamic, dynamic> plantUses;
  final Uint8List imageBytes;
  final Box box;

  const ResultsScreen({
    super.key,
    required this.box,
    required this.imageBytes,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.showButtonsOfScanScreen,
    required this.plantInfo,
    required this.plantUses,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final String commonName;
  late final String scientificName;
  late final String description;
  late final String propagationMethods;
  late final String wateringMax;
  late final String wateringMin;
  late final String isPlantHealty;
  late final String diseaseName;
  late final String diseaseDescription;
  late final String edibleParts;
  late final String edibleUses;
  late final String medicalUses;
  late final String otherUses;
  late final Uint8List imageBytes;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSaved = false;
  late final Map<dynamic, dynamic> plantInfo;
  late final Map<dynamic, dynamic> plantUses;

  @override
  void initState() {
    super.initState();
    _sortPlantInfo();
    setState(() {
      _isLoading = false;
    });
  }

  void _sortPlantInfo() {
    setState(() {
      plantInfo = widget.plantInfo;
      plantUses = widget.plantUses;
      imageBytes = widget.imageBytes;
      var suggestion = plantInfo['result']['classification']['suggestions'];
      commonName =
          suggestion?[0]?['details']?['common_names']?[0]?.toString() ?? "";
      scientificName = suggestion[0]?['name'].toString() ?? "";
      description =
          suggestion?[0]?['details']?['description']?['value']?.toString() ??
              "";
      propagationMethods =
          suggestion?[0]?['details']?['propagation_methods']?.toString() ?? "";
      wateringMax =
          suggestion?[0]?['details']?['watering']?['max']?.toString() ?? "";
      wateringMin =
          suggestion?[0]?['details']?['watering']?['min']?.toString() ?? "";
      isPlantHealty =
          plantInfo['result']['is_healthy']?['binary']?.toString() ?? "true";

      if (plantInfo['result']['disease'] == null ||
          plantInfo['result']['disease']['suggestions'] == null ||
          plantInfo['result']['disease']['suggestions'].isEmpty) {
        diseaseName = "None";
        diseaseDescription = "None";
      } else {
        diseaseName = plantInfo['result']['disease']['suggestions'][0]
                ['details']['common_names']
            .toString();
        diseaseDescription = plantInfo['result']['disease']['suggestions'][0]
                ['details']['description']
            .toString();
      }
      edibleParts = plantUses['Edible Parts'].toString();
      edibleUses = plantUses['Edible Uses'].toString();
      medicalUses = plantUses['Medicinal Uses'].toString();
      otherUses = plantUses['Other Uses'].toString();
    });
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Results'),
          content: const Text(
              'Are you sure you want to save the identification results to the database?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _saveResults();
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _saveResults() async {
    setState(() {
      _isSaving = true;
    });

    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    var username = updateAppProps['userInfo']['username'].toString();

    try {
      await MyBackendService().uploadImageAndResultsInfoToDatabase(
        "filename.jpg",
        widget.imageBytes,
        plantInfo,
        plantUses,
        username,
      );

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      _showSaveSuccessDialog();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorDialog("An error has occurred. Please try again later.");
    }
  }

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Results Saved'),
          content: const Text('The identification results have been saved!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('View Results'),
            ),
          ],
        );
      },
    );
  }

  String getWetnessDescription() {
    int min = int.tryParse(wateringMin) ?? 0;
    int max = int.tryParse(wateringMax) ?? 0;

    String wetnessLevel(int level) {
      switch (level) {
        case 1:
          return 'Dry';
        case 2:
          return 'Medium';
        case 3:
          return 'Wet';
        default:
          return 'Unknown';
      }
    }

    String minDescription = wetnessLevel(min);
    String maxDescription = wetnessLevel(max);

    return 'Prefers $minDescription to $maxDescription environments';
  }

  Column _buildResultsContent() {
    // Get the theme's text color
    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Common Name: $commonName',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Scientific Name: $scientificName',
          style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(description),
        const SizedBox(height: 20),
        const Text(
          'Additional Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(color: textColor, fontSize: 16),
            children: [
              _buildCenteredDescription('Edible Parts:'),
              _buildCenteredDescription(
                  (plantUses['Edible Parts'] ?? []).join(', ')),
              _buildCenteredDescription('Edible Uses:'),
              _buildDescription((plantUses['Edible Uses'] ?? []).join('. ')),
              _buildCenteredDescription('Medicinal Uses:'),
              _buildDescription((plantUses['Medicinal Uses'] ?? []).join('. ')),
              _buildCenteredDescription('Other Uses:'),
              _buildDescription((plantUses['Other Uses'] ?? []).join('. ')),
            ],
          ),
        ),
        const Text(
          'Health Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('Plant is Healthy: $isPlantHealty'),
        Text('Disease Name: $diseaseName'),
        Text('Disease Description: $diseaseDescription'),
        const SizedBox(height: 20),
        if (widget.showButtonsOfScanScreen)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanPage(
                              currentTheme: widget.currentTheme,
                              onThemeChanged: widget.onThemeChanged,
                              box: widget.box,
                            ),
                          ),
                        );
                      },
                      child: const Text('Identify Again.'),
                    ),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _isSaved ? null : _showSaveConfirmationDialog,
                      child: Text(_isSaved ? 'Saved' : 'Save'),
                    ),
            ],
          )
        else
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
      ],
    );
  }

  // Helper methods for building text widgets

  TextSpan _buildDescription(String description) {
    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    return TextSpan(
      text: '$description\n\n',
      style: TextStyle(
        fontSize: 14,
        color: textColor,
      ),
    );
  }

  TextSpan _buildCenteredDescription(String description) {
    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    return TextSpan(
      children: [
        WidgetSpan(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Identification Results"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.memory(
                                  imageBytes,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              _buildResultsContent(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
