import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:replanto/screens/home/views/widgets/plant_screen.dart';
import 'package:user_repository/user_repository.dart';
import '../details_screen.dart';
import 'ModifyProfilePage.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  UserProfileScreen({super.key, required this.userId});

  final FirebasePlantRepo plantRepo = FirebasePlantRepo();
  final FirebaseUserRepo userRepo = FirebaseUserRepo(plantRepo: FirebasePlantRepo());

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
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Failed to fetch user details: $e');
    }
  }

  Future<void> _deletePlant(String userId, String plantId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'plants': FieldValue.arrayRemove([plantId]), // Use arrayRemove to remove the plantId
      });

      await plantRepo.deletePlant(plantId); // Ensure that the plantRepo has the deletePlant method

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
      Fluttertoast.showToast(msg: 'Logout failed');
    }
  }

  void _onProfileButtonPressed(BuildContext context, MyUser user) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyProfilePage(
          userId: userId,
          currentName: user.name,
          currentAge: user.age,
          currentPicture: user.picture,
          userRepository: FirebaseUserRepo(plantRepo: plantRepo),
          plantRepo: plantRepo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final userEntity = MyUserEntity.fromDocument(data);
          final user = MyUser.fromEntity(userEntity);

          return Padding(
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
                        GestureDetector(
                          onTap: () {
                            if (currentUserId == userId) {
                              _onProfileButtonPressed(context, user);
                            }
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.picture),
                            radius: 50,
                          ),
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
                  child: UserPlantsGrid(
                    plants: user.plants,
                    userId: user.userId,
                    plantRepo: plantRepo,
                    onDeletePlant: (userId, plantId) async {
                      await _deletePlant(userId, plantId);
                    },
                    onPlantSelected: (plant) {
                      // Handle plant selection logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            plant: plant,
                            user: user,
                            plantRepo: plantRepo,
                            userRepository: userRepo,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
