import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_repository/plant_repository.dart';

class EditPlantPage extends StatefulWidget {
  final Plant plant;
  final FirebasePlantRepo plantRepo;

  const EditPlantPage({
    super.key,
    required this.plant,
    required this.plantRepo,  // Make plantRepo required
  });
  @override
  _EditPlantPageState createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _humidityController;
  late TextEditingController _pHLevelController;
  late TextEditingController _sunExposureController;
  late TextEditingController _temperatureController;
  late TextEditingController _soilMoistureController;
  late TextEditingController _healthyController;

  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _descriptionController = TextEditingController(text: widget.plant.description);
    _humidityController = TextEditingController(text: widget.plant.humidity.toString());
    _pHLevelController = TextEditingController(text: widget.plant.pHLevel.toString());
    _sunExposureController = TextEditingController(text: widget.plant.sunExposure.toString());
    _temperatureController = TextEditingController(text: widget.plant.temperature.toString());
    _soilMoistureController = TextEditingController(text: widget.plant.soilMoisture.toString());
    _healthyController = TextEditingController(text: widget.plant.healthy.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _humidityController.dispose();
    _pHLevelController.dispose();
    _sunExposureController.dispose();
    _temperatureController.dispose();
    _soilMoistureController.dispose();
    _healthyController.dispose();
    super.dispose();
  }

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

  Future<void> _updatePlant() async {
    final plantId = widget.plant.plantId;
    String? imageUrl = widget.plant.picture;

    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
        return;
      }
    }

    final updatedPlant = {
      'name': _nameController.text,
      'picture': imageUrl,
      'description': _descriptionController.text,
      'humidity': int.tryParse(_humidityController.text) ?? 0,
      'pHLevel': int.tryParse(_pHLevelController.text) ?? 0,
      'sunExposure': int.tryParse(_sunExposureController.text) ?? 0,
      'temperature': int.tryParse(_temperatureController.text) ?? 0,
      'soilMoisture': int.tryParse(_soilMoistureController.text) ?? 0,
      'healthy': int.tryParse(_healthyController.text) ?? 0,
    };

    try {
      await FirebaseFirestore.instance.collection('plants').doc(plantId).update(updatedPlant);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update plant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Plant Name',
                icon: Icons.nature,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
              ),
              _buildTextField(
                controller: _humidityController,
                label: 'Humidity',
                icon: Icons.opacity,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _pHLevelController,
                label: 'pH Level',
                icon: Icons.science,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _sunExposureController,
                label: 'Sun Exposure',
                icon: Icons.wb_sunny,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _temperatureController,
                label: 'Temperature',
                icon: Icons.thermostat,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _soilMoistureController,
                label: 'Soil Moisture',
                icon: Icons.grass,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _healthyController,
                label: 'Healthy',
                icon: Icons.health_and_safety,
                keyboardType: TextInputType.number,
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
                Image.file(_image!, height: 150),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _updatePlant,
                  icon: const Icon(Icons.save),
                  label: const Text('Update Plant'),
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
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
