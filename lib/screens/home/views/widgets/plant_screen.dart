import 'package:flutter/material.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'EditPlantPage.dart';

class UserPlantsGrid extends StatelessWidget {
  final List<Plant> plants;
  final String userId;
  final FirebasePlantRepo plantRepo;
  final Function(String, String) onDeletePlant;

  const UserPlantsGrid({
    required this.plants,
    required this.userId,
    required this.plantRepo,
    required this.onDeletePlant,
    Key? key,
  }) : super(key: key);

  Future<void> _fetchAndDeletePlant(BuildContext context, String plantId) async {
    try {
      // Fetch plant details before deletion
      final plant = await plantRepo.getPlantById(plantId);
      print('Fetched plant ID: $plantId'); // Log the plant ID to the console

      // Proceed to delete the plant
      await onDeletePlant(userId, plantId);
    } catch (e) {
      print('Error fetching plant details: $e');
      Fluttertoast.showToast(msg: 'Failed to fetch plant details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    plant.picture ?? 'https://example.com/default-plant-picture.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  plant.name ?? 'Unnamed plant',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  plant.description ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPlantPage(
                            plant: plant,
                            plantRepo: plantRepo,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Plant'),
                            content: const Text('Are you sure you want to delete this plant?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          if (plant.plantId.isNotEmpty) {
                            await _fetchAndDeletePlant(context, plant.plantId);

                            // Refresh UI after deletion
                            (context as Element).markNeedsBuild(); // Optionally use setState in StatefulWidget
                          } else {
                            Fluttertoast.showToast(msg: 'Invalid plant ID');
                          }
                        }
                      }

                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
