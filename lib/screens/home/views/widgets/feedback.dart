import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackSection extends StatelessWidget {
  final String plantId;

  FeedbackSection({required this.plantId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Leave a comment...',
          ),
          onSubmitted: (comment) {
            FirebaseFirestore.instance.collection('plants').doc(plantId).collection('comments').add({
              'comment': comment,
              'userId': 'currentUserId',
              'timestamp': Timestamp.now(),
            });
          },
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('plants').doc(plantId).collection('comments').orderBy('timestamp').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error loading comments.');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              final comments = snapshot.data?.docs ?? [];
              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    title: Text(comment['comment']),
                    subtitle: Text('By User ID: ${comment['userId']}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
