import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:replanto/screens/home/views/widgets/EditPlantPage.dart';
import 'package:replanto/screens/home/views/widgets/ModifyProfilePage.dart';
import 'package:replanto/screens/home/views/widgets/UserPost.dart';
import 'package:replanto/screens/home/views/widgets/feedback.dart';
import 'package:user_repository/user_repository.dart';

class DetailsScreen extends StatelessWidget {
  final Plant plant;
  final MyUser user;
  final FirebasePlantRepo plantRepo = FirebasePlantRepo();

  DetailsScreen({required this.plant, required this.user, super.key});

  Future<void> _deletePlant(BuildContext context) async {
    try {
      await plantRepo.deletePlant(plant.plantId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant deleted successfully')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete plant: $error')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Plant'),
          content: const Text('Are you sure you want to delete this plant?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
                _deletePlant(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(plant.name, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (plant.userId == userId) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPlantPage(plant: plant),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.person, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModifyProfilePage(
                    userId: user.userId,
                    currentName: user.name ?? 'Unknown',
                    currentAge: user.age ?? 0,
                    currentPicture: user.picture ?? '',
                  ),
                ),
              );
            },
          ),
        ],
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
                    onError: (_, __) => const Icon(Icons.error, size: 100),
                  ),
                ),
                child: plant.picture.isEmpty
                    ? Center(child: Icon(Icons.image, size: 100, color: Colors.grey[400]))
                    : null,
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
              UserInfoSection(userId: plant.userId ?? 'Unknown User ID'),
              const SizedBox(height: 20),
              _buildPlantAttributes(context, plant),
              const SizedBox(height: 20),
              FeedbackSection(plantId: plant.plantId),
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
}
