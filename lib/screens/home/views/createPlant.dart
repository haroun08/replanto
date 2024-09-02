import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPlantScreen extends StatefulWidget {
  final String userId; // Add this line to accept userId

  const AddPlantScreen({Key? key, required this.userId}) : super(key: key); // Modify constructor

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pictureController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _humidityController = TextEditingController();
  final _pHLevelController = TextEditingController();
  final _sunExposureController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _soilMoistureController = TextEditingController();
  final _healthyController = TextEditingController();

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
                controller: _pictureController,
                label: 'Picture URL',
                hintText: 'Enter the picture URL',
                icon: Icons.image,
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
                  onPressed: _submit,
                  icon: Icon(Icons.add),
                  label: Text('Add Plant'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: theme.primaryColor, padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
      final plant = {
        'name': _nameController.text,
        'picture': _pictureController.text,
        'description': _descriptionController.text,
        'humidity': int.tryParse(_humidityController.text) ?? 0,
        'pHLevel': int.tryParse(_pHLevelController.text) ?? 0,
        'sunExposure': int.tryParse(_sunExposureController.text) ?? 0,
        'temperature': int.tryParse(_temperatureController.text) ?? 0,
        'soilMoisture': int.tryParse(_soilMoistureController.text) ?? 0,
        'healthy': int.tryParse(_healthyController.text) ?? 0,
        'userId': widget.userId, // Include the userId here
      };

      try {
        // Add plant to Firestore
        final docRef = await FirebaseFirestore.instance.collection('plants').add(plant);

        // Update user with new plant ID
        final userId = widget.userId;
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'plants': FieldValue.arrayUnion([docRef.id]),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plant added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add plant: $e')),
        );
      }
    }
  }
}
