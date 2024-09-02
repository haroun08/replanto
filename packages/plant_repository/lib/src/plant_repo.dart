import 'models/models.dart';

abstract class PlantRepo {
  Future<List<Plant>> getPlants() ;
  Future<void> addPlant(Plant plant);

}