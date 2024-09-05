import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserPlantsScreen extends StatelessWidget {
  final String userId;

  const UserPlantsScreen({required this.userId, Key? key}) : super(key: key);

  Future<void> _deletePlant(String plantId) async {
    try {
      await FirebaseFirestore.instance.collection('plants').doc(plantId).delete();
      print('Plant deleted successfully');
    } catch (e) {
      print('Error deleting plant: $e');
    }
  }

  Future<void> _updatePlant(String plantId, String newName) async {
    try {
      await FirebaseFirestore.instance.collection('plants').doc(plantId).update({
        'name': newName,
      });
      print('Plant updated successfully');
    } catch (e) {
      print('Error updating plant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('plants').where('userId', isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error fetching plants');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No plants found');
          }

          final plants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final plantId = plant.id;
              final plantName = plant['name'];

              return ListTile(
                title: Text(plantName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Show dialog to edit plant name
                        showDialog(
                          context: context,
                          builder: (context) {
                            final TextEditingController _editController = TextEditingController(text: plantName);
                            return AlertDialog(
                              title: const Text('Edit Plant'),
                              content: TextField(
                                controller: _editController,
                                decoration: const InputDecoration(labelText: 'Plant Name'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _updatePlant(plantId, _editController.text);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deletePlant(plantId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
