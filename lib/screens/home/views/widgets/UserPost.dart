import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:replanto/screens/home/views/widgets/user_screen.dart';

class UserInfoSection extends StatelessWidget {
  final String userId;

  const UserInfoSection({required this.userId, super.key});

  Future<Map<String, String>> _fetchUserData(String userId) async {
    try {
      if (userId.isEmpty) {
        return {'name': 'Unknown User', 'picture': ''};
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('name') && data.containsKey('picture')) {
          return {
            'name': data['name'] ?? 'Unknown',
            'picture': data['picture'] ?? '',
          };
        } else {
          throw Exception('User name or picture field is missing');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {'name': 'Error', 'picture': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _fetchUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error fetching user details: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final userName = snapshot.data!['name']!;
          final userPicture = snapshot.data!['picture']!;
          return Row(
            children: [
              if (userPicture.isNotEmpty)
                CircleAvatar(
                  backgroundImage: NetworkImage(userPicture),
                  radius: 20,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Published by: $userName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(userId: userId),
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
    );
  }
}
