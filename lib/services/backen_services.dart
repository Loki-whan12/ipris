import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class MyBackendService {
  final link = "http://172.20.10.2:5000";
  final headers = {'Content-Type': 'application/json'};

  Future<dynamic> getUserInfo(String username) async {
    Uri url = Uri.parse("$link/users/$username");
    var request = http.Request('GET', url);

    final response = await request.send();
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } else {
      return null;
    }
  }

  Future<dynamic> identifyPlant(Uint8List bytes, String filename) async {
    var headers = {
      'Api-Key': 'nnzZn3wOmR6ADC3MaPtS36rBRYAOmvXHFPFjGRAy8wvqS3nVlE',
      'Content-Type': 'multipart/form-data'
    };
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://plant.id/api/v3/identification?details=common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods&language=en'));
    request.fields.addAll({
      'latitude': '49.207',
      'longitude': '16.608',
      'similar_images': 'true',
      'health': 'all'
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

  Future<dynamic> fetchPlantUses(
      String commonName, String botanicalName) async {
    // Replace spaces with hyphens in commonName and botanicalName
    String sanitizedCommonName = commonName.replaceAll(" ", "-");
    String sanitizedBotanicalName = botanicalName.replaceAll(" ", "-");

    var url = Uri.parse(
        '$link/plants/uses/$sanitizedCommonName/$sanitizedBotanicalName');

    try {
      var response = await http.get(url);
      return jsonDecode(response.body);
    } catch (e) {
      print('Exception during request: $e');
      return null;
    }
  }

  Future<dynamic> identifyPlantAndGetUses(
      Uint8List bytes, String filename) async {
    var identificationResult = await identifyPlant(bytes, filename);
    print(identificationResult.runtimeType);
    if (identificationResult != null) {
      var botanicalName = identificationResult['result']['classification']
                  ?['suggestions']?[0]?['name']
              ?.toString() ??
          "";

      var commonNames = identificationResult['result']['classification']
          ?['suggestions']?[0]?['details']?['common_names'];

      var commonName =
          (commonNames == null) ? botanicalName : commonNames[0].toString();
      var plantUses = await fetchPlantUses(commonName, botanicalName);

      return {
        "message": "success",
        "plant_info": identificationResult,
        "plant_uses": plantUses
      };
    } else {
      return {"error": "Identification failed. Please try again."};
    }
  }

  Future<dynamic> identifyPlantAndGetUsess(
      Uint8List bytes, String filename) async {
    var identificationResult = await identifyPlant(bytes, filename);
    if (identificationResult != null) {
      var botanicalName = identificationResult['result']['classification']
                  ?['suggestions']?[0]?['name']
              ?.toString() ??
          "";
      var commonNames = identificationResult['result']['classification']
          ?['suggestions']?[0]?['details']?['common_names'];

      var commonName = (commonNames == null) ? "" : commonNames[0].toString();
      var plantUses = await fetchPlantUses(commonName, botanicalName);

      return {
        "message": "success",
        "plant_info": identificationResult,
        "plant_uses": plantUses
      };
    } else {
      return {"error": "Identification failed. Please try again."};
    }
  }

  Future<dynamic> fetchPlants(String username) async {
    try {
      Uri url = Uri.parse("$link/plants/$username");
      var request = http.Request('GET', url);

      final response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        return jsonDecode(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching plants: $e');
      throw Exception('Error fetching plants');
    }
  }

  Future<dynamic> deletePlant(String id) async {
    try {
      Uri url = Uri.parse("$link/plants/delete/$id");
      var request = http.Request('DELETE', url);

      final response = await request.send();

      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } catch (e) {
      print('Error Deleting plants: $e');
      throw Exception('Error fetching plants');
    }
  }

  Future<dynamic> addUserToBackendDatabase(Map userInfo) async {
    Uri url = Uri.parse("$link/users/create");
    var request = http.Request('POST', url);

    // Convert userInfo to JSON string
    request.body = jsonEncode(userInfo);
    // Set content type to application/json
    request.headers['Content-Type'] = 'application/json';

    final response = await request.send();
    var data = await response.stream.bytesToString();
    return jsonDecode(data); // Parse JSON response
  }

  Future<dynamic> addReviewDatabase(Map reviewInfo) async {
    Uri url = Uri.parse("$link/comments/create");
    var request = http.Request('POST', url);

    // Convert userInfo to JSON string
    request.body = jsonEncode(reviewInfo);
    // Set content type to application/json
    request.headers['Content-Type'] = 'application/json';

    final response = await request.send();
    var data = await response.stream.bytesToString();
    return jsonDecode(data); // Parse JSON response
  }

  Future<dynamic> fetchReviews() async {
    try {
      Uri url = Uri.parse("$link/comments/all");
      var request = http.Request('GET', url);

      final response = await request.send();

      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } catch (e) {
      print('Error fetching plants: $e');
      throw Exception('Failed ton load reviews');
    }
  }

  Future<dynamic> changeEmail(String username, Map emailInfo) async {
    Uri url = Uri.parse("$link/users/email/$username");
    var request = http.Request('PUT', url);

    request.body = json.encode(emailInfo);
    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } else {
      return null;
    }
  }

  Future<dynamic> getAllUsers() async {
    Uri url = Uri.parse("$link/users/all");
    var request = http.Request('GET', url);

    final response = await request.send();
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } else {
      return null;
    }
  }

  Future<dynamic> changePassowrd(String username, Map passwordInfo) async {
    Uri url = Uri.parse("$link/users/password/$username");
    var request = http.Request('PUT', url);

    request.body = json.encode(passwordInfo);
    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      return jsonDecode(data);
    } else {
      return null;
    }
  }
}
