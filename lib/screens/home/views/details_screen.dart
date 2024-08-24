import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plant_repository/plant_repository.dart';

class DetailsScreen extends StatelessWidget {
  final Plant plant;
  const DetailsScreen(this.plant, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(plant.name, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
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
                  ),
                ),
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
              // Plant Properties
              _buildPlantAttributes(context, plant),
              const SizedBox(height: 20),
              // Action Button (Example for Further Use)
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build plant attribute widgets
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
