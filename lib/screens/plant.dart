import 'dart:convert';

class Plant {
  final int id;
  final String filename;
  final String imageData;
  final Map<String, dynamic> plantInfo;
  final Map<String, dynamic> plantUses;
  final String username;

  Plant({
    required this.id,
    required this.filename,
    required this.imageData,
    required this.plantInfo,
    required this.plantUses,
    required this.username,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      filename: json['filename'],
      imageData: json['image_data'],
      plantInfo: jsonDecode(json['plant_info']),
      plantUses: jsonDecode(json['plant_uses']),
      username: json['username'],
    );
  }
}
