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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
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
            // Plant Details Container
            Container(
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plant Name
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Plant Description
                    Text(
                      plant.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Plant Properties
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Humidity
                        _buildPlantAttribute(
                          context,
                          title: "Humidity",
                          value: "${plant.humidity}%",
                          icon: FontAwesomeIcons.tint,
                        ),
                        // pH Level
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
                        // Sun Exposure
                        _buildPlantAttribute(
                          context,
                          title: "Sun Exposure",
                          value: "${plant.sunExposure}%",
                          icon: FontAwesomeIcons.sun,
                        ),
                        // Temperature
                        _buildPlantAttribute(
                          context,
                          title: "Temp",
                          value: "${plant.temperature}°C",
                          icon: FontAwesomeIcons.thermometerHalf,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Soil Moisture
                        _buildPlantAttribute(
                          context,
                          title: "Soil Moisture",
                          value: "${plant.soilMoisture}%",
                          icon: FontAwesomeIcons.water,
                        ),
                        // Health
                        _buildPlantAttribute(
                          context,
                          title: "Health",
                          value: "${plant.healthy}%",
                          icon: FontAwesomeIcons.heartbeat,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Action Button (Example for Further Use)
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          // Example action: Add your functionality here
                        },
                        style: TextButton.styleFrom(
                          elevation: 3.0,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Learn More",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build plant attribute widgets
  Widget _buildPlantAttribute(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Column(
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
    );
  }
}
