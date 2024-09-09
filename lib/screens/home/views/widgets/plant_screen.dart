import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:user_repository/user_repository.dart';
import '../details_screen.dart';
import 'EditPlantPage.dart';

class UserPlantsGrid extends StatefulWidget {
  final List<Plant> plants;
  final String userId;
  final FirebasePlantRepo plantRepo;
  final Function(String userId, String plantId) onDeletePlant;
  final Function(Plant plant) onPlantSelected; // Callback for plant selection

  const UserPlantsGrid({
    super.key,
    required this.plants,
    required this.userId,
    required this.plantRepo,
    required this.onDeletePlant,
    required this.onPlantSelected,
  });

  @override
  _UserPlantsGridState createState() => _UserPlantsGridState();
}

class _UserPlantsGridState extends State<UserPlantsGrid> {
  Future<void> _fetchAndDeletePlant(BuildContext context, String plantId) async {
    try {
      // Fetch plant details before deletion
      final plant = await widget.plantRepo.getPlantById(plantId);
      print('Fetched plant ID: $plantId'); // Log the plant ID to the console
      _removePlantFromUser(widget.userId, plantId);

      // Proceed to delete the plant
      await widget.onDeletePlant(widget.userId, plantId);
      Fluttertoast.showToast(msg: 'Plant deleted successfully');
    } catch (e) {
      print('Error fetching plant details: $e');
      // If fetch fails, remove plant from user list
      Fluttertoast.showToast(msg: 'Failed to fetch plant details, plant removed from user list');
    }
  }

  Future<void> _removePlantFromUser(String userId, String plantId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'plants': FieldValue.arrayRemove([plantId]),
      });
      print('Removed plant ID: $plantId from user');
    } catch (e) {
      print('Error removing plant from user: $e');
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
      itemCount: widget.plants.length,
      itemBuilder: (context, index) {
        final plant = widget.plants[index];

        return GestureDetector(
          onTap: () {
            // Call the callback for plant selection
            widget.onPlantSelected(plant);

            // Navigate to DetailsScreen when a plant is selected
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  plant: plant,
                  user: MyUser(
                    userId: widget.userId,
                    email: '', // Provide appropriate value if necessary
                    name: '',  // Provide appropriate value if necessary
                    age: 0,    // Provide appropriate value if necessary
                    picture: '', // Provide appropriate value if necessary
                    plants: widget.plants, // Pass the list of plants
                  ),
                  plantRepo: widget.plantRepo,
                  userRepository: FirebaseUserRepo(plantRepo: widget.plantRepo),
                ),
              ),
            );
          },
          child: Card(
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
                    plant.plantId ?? 'No description',
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
                              plantRepo: widget.plantRepo,
                              userId: widget.userId,
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
                            setState(() {}); // Refresh UI after deletion
                          } else {
                            Fluttertoast.showToast(msg: 'Invalid plant ID');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
