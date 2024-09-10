import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/plant_entity.dart';

class Plant {
  final String plantId;
  final String picture;
  final String name;
  final String description;
  final int humidity;
  final int pHLevel;
  final int sunExposure;
  final int temperature;
  final int soilMoisture;
  final int healthy;
  final String userId;

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
    required this.healthy,
    required this.userId,
  });

  Plant copyWith({
    String? plantId,
    String? picture,
    String? name,
    String? description,
    int? humidity,
    int? pHLevel,
    int? sunExposure,
    int? temperature,
    int? soilMoisture,
    int? healthy,
    String? userId,
  }) {
    return Plant(
      plantId: plantId ?? this.plantId,
      picture: picture ?? this.picture,
      name: name ?? this.name,
      description: description ?? this.description,
      humidity: humidity ?? this.humidity,
      pHLevel: pHLevel ?? this.pHLevel,
      sunExposure: sunExposure ?? this.sunExposure,
      temperature: temperature ?? this.temperature,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      healthy: healthy ?? this.healthy,
      userId: userId ?? this.userId,
    );
  }

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
      healthy: healthy,
      userId: userId,
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
      healthy: entity.healthy,
      userId: entity.userId,
    );
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      plantId: map['plantId'] as String,
      picture: map['picture'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      humidity: map['humidity'] as int,
      pHLevel: map['pHLevel'] as int,
      sunExposure: map['sunExposure'] as int,
      temperature: map['temperature'] as int,
      soilMoisture: map['soilMoisture'] as int,
      healthy: map['healthy'] as int,
      userId: map['userId'] as String,
    );
  }
  factory Plant.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Plant(
      plantId: data['plantId'] as String,
      picture: data['picture'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      humidity: data['humidity'] as int,
      pHLevel: data['pHLevel'] as int,
      sunExposure: data['sunExposure'] as int,
      temperature: data['temperature'] as int,
      soilMoisture: data['soilMoisture'] as int,
      healthy: data['healthy'] as int,
      userId: data['userId'] as String,
    );
  }

}
