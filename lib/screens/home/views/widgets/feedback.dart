import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackSection extends StatefulWidget {
  final String plantId;

  const FeedbackSection({Key? key, required this.plantId}) : super(key: key);

  @override
  _FeedbackSectionState createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  final TextEditingController _commentController = TextEditingController();

  Future<String> _fetchUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Unknown';
      } else {
        return 'User not found';
      }
    } catch (e) {
      return 'Error';
    }
  }

  Future<String> _fetchUserPicture(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['picture'] ?? 'https://example.com/default-picture.jpg';
      } else {
        return 'https://example.com/default-picture.jpg';
      }
    } catch (e) {
      return 'https://example.com/default-picture.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Leave a comment...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (_commentController.text.isNotEmpty && userId != null) {
                  await FirebaseFirestore.instance
                      .collection('plants')
                      .doc(widget.plantId)
                      .collection('comments')
                      .add({
                    'comment': _commentController.text,
                    'userId': userId,
                    'timestamp': Timestamp.now(),
                  });
                  _commentController.clear();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('plants')
              .doc(widget.plantId)
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
                final userId = comment['userId'];
                return FutureBuilder<String>(
                  future: _fetchUserName(userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (userSnapshot.hasError) {
                      return const Text('Error fetching user details');
                    } else if (!userSnapshot.hasData) {
                      return const Text('Unknown user');
                    }

                    final userName = userSnapshot.data!;
                    return FutureBuilder<String>(
                      future: _fetchUserPicture(userId),
                      builder: (context, pictureSnapshot) {
                        if (pictureSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (pictureSnapshot.hasError) {
                          return const Icon(Icons.error);
                        } else if (pictureSnapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(pictureSnapshot.data!),
                            ),
                            title: Text(userName),
                            subtitle: Text(comment['comment']),
                            trailing: Text(
                              (comment['timestamp'] as Timestamp).toDate().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        } else {
                          return const Icon(Icons.error);
                        }
                      },
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
