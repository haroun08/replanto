import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddPlantScreen extends StatefulWidget {
  final String userId;

  const AddPlantScreen({super.key, required this.userId});

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _humidityController = TextEditingController();
  final _pHLevelController = TextEditingController();
  final _sunExposureController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _soilMoistureController = TextEditingController();
  final _healthyController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('plant_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(image);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Plant'),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Plant Name',
                hintText: 'Enter the plant name',
                icon: Icons.nature,
                validatorMessage: 'Please enter a name',
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Enter a brief description',
                icon: Icons.description,
              ),
              _buildTextField(
                controller: _humidityController,
                label: 'Humidity',
                hintText: 'Enter humidity level',
                icon: Icons.opacity,
                keyboardType: TextInputType.number,
                validatorMessage: 'Please enter humidity',
              ),
              _buildTextField(
                controller: _pHLevelController,
                label: 'pH Level',
                hintText: 'Enter pH level',
                icon: Icons.science,
                keyboardType: TextInputType.number,
                validatorMessage: 'Please enter pH Level',
              ),
              _buildTextField(
                controller: _sunExposureController,
                label: 'Sun Exposure',
                hintText: 'Enter sun exposure level',
                icon: Icons.wb_sunny,
                keyboardType: TextInputType.number,
                validatorMessage: 'Please enter sun exposure',
              ),
              _buildTextField(
                controller: _temperatureController,
                label: 'Temperature',
                hintText: 'Enter temperature',
                icon: Icons.thermostat,
                keyboardType: TextInputType.number,
                validatorMessage: 'Please enter temperature',
              ),
              _buildTextField(
                controller: _soilMoistureController,
                label: 'Soil Moisture',
                hintText: 'Enter soil moisture level',
                icon: Icons.grass,
                keyboardType: TextInputType.number,
                validatorMessage: 'Please enter soil moisture',
              ),
              _buildTextField(
                controller: _healthyController,
                label: 'Healthy',
                hintText: 'Enter healthy level',
                icon: Icons.health_and_safety,
                keyboardType: TextInputType.number,
                validatorMessage: 'Please enter healthy level',
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Pick Image'),
                ),
              ),
              const SizedBox(height: 20),
              if (_image != null)
                Image.file(_image!, height: 150), // Display picked image
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Plant'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? validatorMessage,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: keyboardType,
        validator: validatorMessage != null
            ? (value) => value!.isEmpty ? validatorMessage : null
            : null,
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick an image')),
        );
        return;
      }

      String? imageUrl = await _uploadImage(_image!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
        return;
      }

      try {
        final plantData = {
          'name': _nameController.text,
          'picture': imageUrl,
          'description': _descriptionController.text,
          'humidity': int.tryParse(_humidityController.text) ?? 0,
          'pHLevel': int.tryParse(_pHLevelController.text) ?? 0,
          'sunExposure': int.tryParse(_sunExposureController.text) ?? 0,
          'temperature': int.tryParse(_temperatureController.text) ?? 0,
          'soilMoisture': int.tryParse(_soilMoistureController.text) ?? 0,
          'healthy': int.tryParse(_healthyController.text) ?? 0,
          'userId': widget.userId,
        };

        final docRef = await FirebaseFirestore.instance.collection('plants').add(plantData);
        final plantId = docRef.id;
        log('Plant document added with ID: $plantId');

        final userPlantData = {
          'plantId': plantId,
          ...plantData,
        };

        final userId = widget.userId;
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'plants': FieldValue.arrayUnion([userPlantData]),
        });
        log('Updated user document for userId: $userId with new plantId: $plantId');

        // Navigate back and show success message
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plant added successfully!')),
        );
      } catch (e) {
        log('Error adding plant: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add plant: $e')),
        );
      }
    }
  }

}
