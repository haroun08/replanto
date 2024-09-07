import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'EditPlantPage.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  UserProfileScreen({required this.userId});

  Future<MyUser> _fetchUserDetails(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final userEntity = MyUserEntity.fromDocument(data);
        return MyUser.fromEntity(userEntity);
      } else {
        throw Exception('User not found');
      }
    } catch (e, stackTrace) {
      print('Error fetching user details: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch user details: $e');
    }
  }

  Future<void> _deletePlant(String plantId) async {
    try {
      if (plantId.isEmpty) {
        Fluttertoast.showToast(msg: 'Invalid plant ID');
        return;
      }
      await PlantRepo.deletePlant(plantId);  // Use the repository to delete the plant
      Fluttertoast.showToast(msg: 'Plant deleted successfully');
    } catch (e) {
      print('Error deleting plant: $e');
      Fluttertoast.showToast(msg: 'Failed to delete plant');
    }
  }


  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MyUser>(
        future: _fetchUserDetails(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No user data found.'));
          }

          final user = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(user.name),  // Display user's name in the AppBar
              backgroundColor: Colors.green,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.picture),
                            radius: 50,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Email: ${user.email}'),
                                Text('Age: ${user.age}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Plants:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.8, // Adjust aspect ratio to fit content
                      ),
                      itemCount: user.plants.length,
                      itemBuilder: (context, index) {
                        final plant = user.plants[index];

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
                                  // Edit Button
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPlantPage(
                                            plant: plant, // Pass the entire plant object
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      bool? confirmDelete = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Delete Plant'),
                                          content: Text('Are you sure you want to delete this plant?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Delete'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmDelete == true) {
                                        _deletePlant(plant.plantId);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
