import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:replanto/screens/home/views/widgets/user_screen.dart';
import 'package:user_repository/user_repository.dart';

class DetailsScreen extends StatelessWidget {
  final Plant plant;
  const DetailsScreen(this.plant, {super.key});

  Future<String> _fetchUserName(String userId) async {
    try {
      print('Fetching user details for userId: $userId'); // Debug print
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return data['name'] ?? 'Unknown';
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(plant.name, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Image
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(3, 3),
                      blurRadius: 5,
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(plant.picture),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                plant.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                plant.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<String>(
                future: _fetchUserName(plant.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error fetching user details: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final userName = snapshot.data!;
                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(plant.picture),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Published by: $userName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserProfileScreen(userId: plant.userId),
                              ),
                            );
                          },
                          child: const Text('View Profile'),
                        ),
                      ],
                    );
                  } else {
                    return const Text('User details not found');
                  }
                },
              ),

              const SizedBox(height: 20),
              _buildPlantAttributes(context, plant),
              const SizedBox(height: 20),
              _buildFeedbackSection(context, plant.plantId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantAttributes(BuildContext context, Plant plant) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPlantAttribute(
              context,
              title: "Humidity",
              value: "${plant.humidity}%",
              icon: FontAwesomeIcons.tint,
            ),
            _buildPlantAttribute(
              context,
              title: "pH Level",
              value: "${plant.pHLevel}",
              icon: FontAwesomeIcons.flask,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPlantAttribute(
              context,
              title: "Sun Exposure",
              value: "${plant.sunExposure}%",
              icon: FontAwesomeIcons.sun,
            ),
            _buildPlantAttribute(
              context,
              title: "Temperature",
              value: "${plant.temperature}°C",
              icon: FontAwesomeIcons.thermometerHalf,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPlantAttribute(
              context,
              title: "Soil Moisture",
              value: "${plant.soilMoisture}%",
              icon: FontAwesomeIcons.water,
            ),
            _buildPlantAttribute(
              context,
              title: "Health",
              value: "${plant.healthy}%",
              icon: FontAwesomeIcons.heartbeat,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlantAttribute(BuildContext context,
      {required String title, required String value, required IconData icon}) {
    return Expanded(
      child: Column(
        children: [
          FaIcon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context, String plantId) {
    final TextEditingController commentController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: commentController,
          decoration: InputDecoration(
            hintText: 'Leave a comment...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (commentController.text.isNotEmpty && userId != null) {
                  await FirebaseFirestore.instance
                      .collection('plants')
                      .doc(plantId)
                      .collection('comments')
                      .add({
                    'comment': commentController.text,
                    'userId': userId, // Use actual user ID
                    'timestamp': Timestamp.now(),
                  });
                  commentController.clear();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('plants')
              .doc(plantId)
              .collection('comments')
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching comments');
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No comments yet');
            }

            final comments = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return FutureBuilder<String>(
                  future: _fetchUserName(comment['userId']),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (userSnapshot.hasError) {
                      return const Text('Error fetching user details');
                    } else if (!userSnapshot.hasData) {
                      return const Text('Unknown user');
                    }

                    final userName = userSnapshot.data!;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(plant.picture),
                      ),
                      title: Text(userName),
                      subtitle: Text(comment['comment']),
                      trailing: Text(
                        (comment['timestamp'] as Timestamp).toDate().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
