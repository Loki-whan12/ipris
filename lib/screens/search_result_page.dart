import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/backen_services.dart';

class SearchResultPage extends StatefulWidget {
  final String accessToken;
  final String base64Image;

  const SearchResultPage({
    super.key,
    required this.accessToken,
    required this.base64Image,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  bool isLoading = true;
  String name = "";
  String commonName = "";
  String description = "";
  var plantUses;
  String urlImage = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize data properly by awaiting the asynchronous function
  Future<void> _initializeData() async {
    try {
      var response = await _fetchPlantDetails(widget.accessToken);
      print(response);
      urlImage = response['image']?['value'].toString() ?? "";

      var botanicalName = response['name']?.toString() ?? "";

      var commonNames = response['common_names'];

      var commonName = (commonNames == null)
          ? botanicalName
          : commonNames?[0]?.toString() ?? "";

      plantUses =
          await MyBackendService().fetchPlantUses(commonName, botanicalName);
      populateData(response);
      plantUses = plantUses['plant_uses'];
      setState(() {
        isLoading = false; // Update state once data is loaded
      });
    } catch (e) {
      setState(() {
        isLoading =
            false; // Ensure the loading indicator is removed even on error
      });
      print("Error fetching plant details: $e");
    }
  }

  // Populate the data with the response from the async call
  void populateData(Map<String, dynamic> response) {
    // Use setState to ensure UI updates with new data
    setState(() {
      name = response['name']?.toString() ?? "Unknown scientific name";
      commonName = response['common_names']?.isNotEmpty == true
          ? response['common_names'][0].toString()
          : "Unknown common name";
      description = response['description']?['value']?.toString() ??
          "No description available";
    });
  }

  // Fetch plant details with async/await to handle the response
  Future<Map<String, dynamic>> _fetchPlantDetails(String accessToken) async {
    final response =
        await MyBackendService().retrieveIdentification(accessToken);

    return response;
  }

  // Convert base64 string to bytes with error handling
  Future<Uint8List?> _convertBase64ToBytes(String base64String) async {
    try {
      if (base64String.isEmpty) return null;
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 string: $e');
      return null; // Return null if decoding fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
      ),
      body: isLoading
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
                              FutureBuilder<Uint8List?>(
                                future:
                                    _convertBase64ToBytes(widget.base64Image),
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                            Icons.image_not_supported,
                                            size: 50);
                                      },
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Image.network(
                                'https://plant-id.ams3.cdn.digitaloceanspaces.com/knowledge_base/wikidata/550/5501026f9ec59f1e26f35d54f3b1bf0af9d83556.jpg',
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),

                              // Display the Common Name, Scientific Name, and Description
                              Text(
                                'Common Name: $commonName',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Scientific Name: $name',
                                style: const TextStyle(
                                    fontSize: 20, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Description:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                description,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Text(
                                'Additional Information',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16),
                                  children: [
                                    _buildCenteredDescription('Edible Parts:'),
                                    _buildCenteredDescription(
                                        (plantUses['Edible Parts'] ?? [])
                                            .join(', ')),
                                    _buildCenteredDescription('Edible Uses:'),
                                    _buildDescription(
                                        (plantUses['Edible Uses'] ?? [])
                                            .join('. ')),
                                    _buildCenteredDescription(
                                        'Medicinal Uses:'),
                                    _buildDescription(
                                        (plantUses['Medicinal Uses'] ?? [])
                                            .join('. ')),
                                    _buildCenteredDescription('Other Uses:'),
                                    _buildDescription(
                                        (plantUses['Other Uses'] ?? [])
                                            .join('. ')),
                                  ],
                                ),
                              ),
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
}
