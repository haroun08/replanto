class PlantEntity {
  // Fields
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
  String userId;

  // Constructor
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
    required this.healthy,
    required this.userId,
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
      'healthy': healthy,
      'userId': userId,
    };
  }

  static PlantEntity fromDocument(Map<String, dynamic> doc) {
    return PlantEntity(
      plantId: doc['plantId'] ?? '',
      picture: doc['picture'] ?? '',
      name: doc['name'] ?? '',
      description: doc['description'] ?? '',
      humidity: doc['humidity'] ?? 0,
      pHLevel: doc['pHLevel'] ?? 0,
      sunExposure: doc['sunExposure'] ?? 0,
      temperature: doc['temperature'] ?? 0,
      soilMoisture: doc['soilMoisture'] ?? 0,
      healthy: doc['healthy'] ?? 0,
      userId: doc['userId'] ?? '',
    );
  }
}
