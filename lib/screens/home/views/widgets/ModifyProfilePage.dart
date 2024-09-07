import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifyProfilePage extends StatefulWidget {
  final String userId;
  final String currentName;
  final int currentAge;
  final String currentPicture;

  const ModifyProfilePage({
    required this.userId,
    required this.currentName,
    required this.currentAge,
    required this.currentPicture,
    Key? key,
  }) : super(key: key);

  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _pictureController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _ageController = TextEditingController(text: widget.currentAge.toString());
    _pictureController = TextEditingController(text: widget.currentPicture);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _pictureController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

      await userDoc.update({
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text) ?? widget.currentAge,
        'picture': _pictureController.text,
      });

      // Show success message and pop the page
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pictureController,
              decoration: const InputDecoration(labelText: 'Profile Picture URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
