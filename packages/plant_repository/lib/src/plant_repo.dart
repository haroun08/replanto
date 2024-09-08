import 'models/models.dart';

abstract class PlantRepo {
  Future<List<Plant>> getPlants() ;
  Future<void> addPlant(Plant plant);
  Future<void> deletePlant(String plantId);
  Future<void> updatePlant(String plantId, Map<String, dynamic> updatedFields);
  Future<Plant> getPlantById(String plantId);
}