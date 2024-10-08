import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:plant_repository/plant_repository.dart';
import 'package:user_repository/user_repository.dart';
import '../details_screen.dart';
import 'EditPlantPage.dart';

class UserPlantsGrid extends StatefulWidget {
  final List<Plant> plants;
  final String userId;
  final FirebasePlantRepo plantRepo;
  final FirebaseUserRepo userRepo;

  final Function(String userId, String plantId) onDeletePlant;
  final Function(Plant plant) onPlantSelected;

  const UserPlantsGrid({
    super.key,
    required this.plants,
    required this.userId,
    required this.plantRepo,
    required this.onDeletePlant,
    required this.onPlantSelected,
    required this.userRepo,
  });

  @override
  _UserPlantsGridState createState() => _UserPlantsGridState();
}

class _UserPlantsGridState extends State<UserPlantsGrid> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    // Get the current logged-in user's ID
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _fetchAndDeletePlant(BuildContext context, String plantId) async {
    try {
      final plant = await widget.plantRepo.getPlantById(plantId);
      print('Fetched plant ID: $plantId');

      await widget.userRepo.deletePlantFromUser(widget.userId, plantId);
      await widget.onDeletePlant(widget.userId, plantId);

      Fluttertoast.showToast(msg: 'Plant deleted successfully');
    } catch (e) {
      print('Error deleting plant: $e');
      Fluttertoast.showToast(msg: 'Error deleting plant: $e');
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

                // Only show edit and delete buttons if the logged-in user is the owner of the profile
                if (currentUserId == widget.userId)
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
