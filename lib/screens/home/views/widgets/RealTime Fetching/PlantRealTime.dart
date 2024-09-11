class SensorData {
  final String timestamp;
  final double heatIndex;
  final double humidity;
  final double temperature;
  final int soilMoisture;
  final String rain;
  final int numeric;

  SensorData({
    required this.timestamp,
    required this.heatIndex,
    required this.humidity,
    required this.temperature,
    required this.soilMoisture,
    required this.rain,
    required this.numeric,
  });

  factory SensorData.fromJson(Map<dynamic, dynamic> json) {
    return SensorData(
      timestamp: json['timestamp'] ?? '0', // Default to '0' if null
      heatIndex: (json['heatIndex'] as num?)?.toDouble() ?? 0.0, // Cast int to double if necessary
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0, // Cast int to double if necessary
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0, // Cast int to double if necessary
      soilMoisture: (json['soilMoisture'] as int?) ?? 0, // Default to 0 if null
      rain: json['rain'] ?? 'No Data', // Default to 'No Data' if null
      numeric: (json['numeric'] as int?) ?? 0, // Default to 0 if null
    );
  }
}
