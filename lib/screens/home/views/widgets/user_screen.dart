import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  UserProfileScreen({required this.userId});

  Future<MyUser> _fetchUserDetails(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;

        print('Retrieved user data: $data');

        final plantIds = List<String>.from(data['plants'] ?? []);

        final plantFutures = plantIds.map((plantId) async {
          if (plantId.isEmpty) {
            throw Exception('Invalid plant ID');
          }

          try {
            final plantDoc = await FirebaseFirestore.instance.collection('plants').doc(plantId).get();
            if (plantDoc.exists) {
              return PlantEntity.fromDocument(plantDoc.data()!);
            } else {
              throw Exception('Plant not found');
            }
          } catch (e) {
            print('Error fetching plant $plantId: $e');
            rethrow;
          }
        }).toList();

        final plants = await Future.wait(plantFutures);

        final userEntity = MyUserEntity(
          userId: data['userId'] ?? 'Unknown',
          email: data['email'] ?? 'No email',
          name: data['name'] ?? 'No name',
          age: data['age'] ?? 0,
          picture: data['picture'] ?? '', // Provide a default value
          plants: plants,
        );

        return MyUser.fromEntity(userEntity);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Failed to fetch user details: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.green,
      ),
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          Text('Email: ${user.email}'),
                          Text('Age: ${user.age}'),
                        ],
                      ),
                    ),
                  ],
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
                      childAspectRatio: 1,
                    ),
                    itemCount: user.plants.length,
                    itemBuilder: (context, index) {
                      final plant = user.plants[index];
                      return Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                plant.picture,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                plant.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                plant.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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