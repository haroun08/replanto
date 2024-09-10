import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:replanto/screens/home/views/widgets/user_screen.dart';

class FeedbackSection extends StatefulWidget {
  final String plantId;

  const FeedbackSection({Key? key, required this.plantId}) : super(key: key);

  @override
  _FeedbackSectionState createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyingToCommentId; // Track which comment user is replying to
  final TextEditingController _replyController = TextEditingController();
  String? _editingCommentId; // Track which comment is being edited

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

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }

  void _postComment() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (_commentController.text.isNotEmpty && userId != null) {
      await FirebaseFirestore.instance.collection('plants').doc(widget.plantId).collection('comments').add({
        'comment': _commentController.text,
        'userId': userId,
        'timestamp': Timestamp.now(),
        'replies': [], // Initialize an empty replies list
      });
      _commentController.clear();
    }
  }

  void _postReply(String commentId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (_replyController.text.isNotEmpty && userId != null) {
      await FirebaseFirestore.instance
          .collection('plants')
          .doc(widget.plantId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .add({
        'comment': _replyController.text,
        'userId': userId,
        'timestamp': Timestamp.now(),
      });
      setState(() {
        _replyingToCommentId = null; // Reset replying to comment
        _replyController.clear();
      });
    }
  }

  void _editComment(String commentId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (_commentController.text.isNotEmpty && userId != null) {
      await FirebaseFirestore.instance
          .collection('plants')
          .doc(widget.plantId)
          .collection('comments')
          .doc(commentId)
          .update({
        'comment': _commentController.text,
        'timestamp': Timestamp.now(),
      });
      setState(() {
        _editingCommentId = null; // Reset editing comment
      });
      _commentController.clear();
    }
  }

  void _deleteComment(String commentId) async {
    await FirebaseFirestore.instance
        .collection('plants')
        .doc(widget.plantId)
        .collection('comments')
        .doc(commentId)
        .delete();
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
              onPressed: () {
                if (_editingCommentId != null) {
                  _editComment(_editingCommentId!);
                } else {
                  _postComment();
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
                final commentId = comment.id;
                final currentUser = FirebaseAuth.instance.currentUser;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
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
                                    leading: GestureDetector(
                                      onTap: () => _navigateToUserProfile(userId),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(pictureSnapshot.data!),
                                      ),
                                    ),
                                    title: Text(userName),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(comment['comment']),
                                        const SizedBox(height: 5),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('plants')
                                              .doc(widget.plantId)
                                              .collection('comments')
                                              .doc(commentId)
                                              .collection('replies')
                                              .orderBy('timestamp')
                                              .snapshots(),
                                          builder: (context, replySnapshot) {
                                            if (replySnapshot.hasData &&
                                                replySnapshot.data!.docs.isNotEmpty) {
                                              final replies = replySnapshot.data!.docs;
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                const NeverScrollableScrollPhysics(),
                                                itemCount: replies.length,
                                                itemBuilder: (context, replyIndex) {
                                                  final reply = replies[replyIndex];
                                                  return ListTile(
                                                    leading: const Icon(Icons.reply),
                                                    title: Text(reply['comment']),
                                                    trailing: Text(
                                                      DateFormat('HH:mm').format(
                                                          (reply['timestamp']
                                                          as Timestamp)
                                                              .toDate()),
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 5),
                                        if (_replyingToCommentId == commentId)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 40.0),
                                            child: Column(
                                              children: [
                                                TextField(
                                                  controller: _replyController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Write a reply...',
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(Icons.send),
                                                      onPressed: () =>
                                                          _postReply(commentId),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                        if (_replyingToCommentId == null)
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _replyingToCommentId = commentId;
                                              });
                                            },
                                            child: const Text('Reply'),
                                          ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Text('No user picture');
                                }
                              },
                            );
                          },
                        ),
                        if (userId == currentUser?.uid)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    _commentController.text = comment['comment'];
                                    _editingCommentId = commentId;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteComment(commentId),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
