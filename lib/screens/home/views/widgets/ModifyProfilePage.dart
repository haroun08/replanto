import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_repository/plant_repository.dart';
import 'dart:io';
import 'package:user_repository/user_repository.dart';

class ModifyProfilePage extends StatefulWidget {
  final String userId;
  final String currentName;
  final int currentAge;
  final String currentPicture;
  final UserRepository userRepository;
  final FirebasePlantRepo plantRepo;

  const ModifyProfilePage({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentAge,
    required this.currentPicture,
    required this.userRepository,
    required this.plantRepo,
  });

  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  File? _pickedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _ageController = TextEditingController(text: widget.currentAge.toString());
    _imageUrl = widget.currentPicture;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${widget.userId}.jpg');

      final uploadTask = await storageRef.putFile(_pickedImage!);
      final url = await uploadTask.ref.getDownloadURL();

      setState(() {
        _imageUrl = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    try {
      String name = _nameController.text;
      int age = int.tryParse(_ageController.text) ?? widget.currentAge;
      String? picture = _imageUrl ?? widget.currentPicture;

      Map<String, dynamic> updatedData = {
        'name': name,
        'age': age,
        'picture': picture,
      };

      await widget.userRepository.updateProfileData(widget.userId, updatedData);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Profile'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundImage: NetworkImage(_imageUrl ?? widget.currentPicture),
                radius: 60,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: theme.colorScheme.primary),
              ),
              style: TextStyle(color: theme.colorScheme.onBackground),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: theme.colorScheme.primary),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.colorScheme.onBackground),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
