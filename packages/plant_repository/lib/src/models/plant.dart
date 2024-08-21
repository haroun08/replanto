import '../entities/plant_entity.dart';
import 'macros.dart';

class Plant {
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

  Plant({
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

  PlantEntity toEntity() {
    return PlantEntity(
      plantId: plantId,
      picture: picture,
      name: name,
      description: description,
      humidity: humidity,
      pHLevel: pHLevel,
      sunExposure: sunExposure,
      temperature: temperature,
      soilMoisture: soilMoisture,
      healthy :healthy
    );
  }

  static Plant fromEntity(PlantEntity entity) {
    return Plant(
      plantId: entity.plantId,
      picture: entity.picture,
      name: entity.name,
      description: entity.description,
      humidity: entity.humidity,
      pHLevel: entity.pHLevel,
      sunExposure: entity.sunExposure,
      temperature: entity.temperature,
      soilMoisture: entity.soilMoisture,
      healthy: entity.healthy
    );
  }
}