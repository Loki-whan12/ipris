import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadApiImage {
  Future<dynamic> uploadImage(Uint8List bytes, String filename) async {
    Uri url = Uri.parse("https://api.escuelajs.co/api/v1/files/upload");
    var request = http.MultipartRequest("Post", url);
    var myFile = http.MultipartFile(
        "file", http.ByteStream.fromBytes(bytes), bytes.length,
        filename: filename);

    request.files.add(myFile);

    final response = await request.send();
    if (response.statusCode == 201) {
      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } else {
      return null;
    }
  }

  Future<void> uploadImageAndResultsInfoToDatabase(String filename,
      Uint8List bytes, Map plantInfo, Map plantUses, String username) async {
    try {
      // Prepare the multipart request
      final url = Uri.parse('http://172.20.10.4:5000/plants/create');
      var request = http.MultipartRequest('POST', url);

      // Convert maps to JSON strings
      String plantInfoJson = jsonEncode(plantInfo);
      String plantUsesJson = jsonEncode(plantUses);

      // Print to debug
      print('plantInfo: ${plantInfoJson.runtimeType}');
      print('plantUses: ${plantUsesJson.runtimeType}');

      // Add fields to the request
      request.fields['plant_info'] = plantInfoJson;
      request.fields['plant_uses'] = plantUsesJson;
      request.fields['username'] = username;

      // Add the image file as a multipart
      request.files.add(
        http.MultipartFile.fromBytes(
          'image_data',
          bytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send the request
      final response = await request.send();

      if (response.statusCode == 201) {
        print('Plant created successfully');
      } else {
        final responseData = await response.stream.bytesToString();
        print('Failed to create plant: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<dynamic> uploadPlantImage(Uint8List bytes, String filename) async {
    var headers = {
      'Api-Key': 'yGIHaWkC7HPXnXdByo9iHk8Znnpb7cqyJcAlgbdx36oZlk6LfI',
      'Content-Type': 'multipart/form-data'
    };
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://plant.id/api/v3/identification?details=common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods&language=en'));
    request.fields.addAll({
      'latitude': '49.207',
      'longitude': '16.608',
      'similar_images': 'true'
    });
    var myFile = http.MultipartFile(
        "file", http.ByteStream.fromBytes(bytes), bytes.length,
        filename: filename);

    request.files.add(myFile);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } else {
      return null;
    }
  }
}
