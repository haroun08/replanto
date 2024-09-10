import 'package:intl/intl.dart';
import 'package:plant_repository/plant_repository.dart';

List<DateTime> calculateWateringDates(Plant plant, DateTime startDate) {
  final List<DateTime> wateringDates = [];
  final int wateringInterval;

  // Determine the watering interval based on soil moisture
  if (plant.soilMoisture < 20) {
    wateringInterval = 3;
  } else if (plant.soilMoisture <= 50) {
    wateringInterval = 5;
  } else {
    wateringInterval = 7;
  }

  DateTime currentDate = startDate;
  while (currentDate.isBefore(DateTime.now().add(const Duration(days: 365)))) {
    wateringDates.add(currentDate);
    currentDate = currentDate.add(Duration(days: wateringInterval));
  }

  return wateringDates;
}
