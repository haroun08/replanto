import '../models/macros.dart';
import 'macros_entity.dart';

class PlantEntity {
  String plantId;
  String picture;
  String name;
  String description;
  int humidity;
  int pHLevel;
  int sunExposure;
  int temperature;
  int soilMoisture;
  int healthy;

  PlantEntity({
    required this.plantId,
    required this.picture,
    required this.name,
    required this.description,
    required this.humidity,
    required this.pHLevel,
    required this.sunExposure,
    required this.temperature,
    required this.soilMoisture,
    required this.healthy
  });

  Map<String, Object?> toDocument() {
    return {
      'plantId': plantId,
      'picture': picture,
      'name': name,
      'description': description,
      'humidity': humidity,
      'pHLevel': pHLevel,
      'sunExposure': sunExposure,
      'temperature': temperature,
      'soilMoisture': soilMoisture,
      'healthy': healthy
    };
  }

  static PlantEntity fromDocument(Map<String, dynamic> doc) {
    return PlantEntity(
      plantId: doc['plantId'],
      picture: doc['picture'],
      name: doc['name'],
      description: doc['description'],
      humidity: doc['humidity'],
      pHLevel: doc['pHLevel'],
      sunExposure: doc['sunExposure'],
      temperature: doc['temperature'],
      soilMoisture: doc['soilMoisture'],
      healthy : doc['healthy']

    );
  }
}