import 'package:flutter/material.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:plant_repository/plant_repository.dart';

import '../details_screen.dart';

class CarouselPanel extends StatelessWidget {
  final List plantDocuments;

  const CarouselPanel({super.key, required this.plantDocuments});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StackedCardCarousel(
        items: plantDocuments.map((plantData) {
          final name = plantData['name'] ?? 'Unknown Plant';
          final pictureUrl = plantData['picture'];

          final plant = Plant(
            plantId: plantData.id,
            name: name,
            picture: pictureUrl ?? '',
            description: plantData['description'] ?? 'No description available.',
            humidity: plantData['humidity'] ?? 0,
            pHLevel: plantData['pHLevel'] ?? 0,
            sunExposure: plantData['sunExposure'] ?? 0,
            temperature: plantData['temperature'] ?? 0,
            soilMoisture: plantData['soilMoisture'] ?? 0,
            healthy: plantData['healthy'] ?? 0,
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(plant),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pictureUrl != null
                    ? Image.network(
                  pictureUrl,
                  width: 250,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.local_florist, size: 150),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),

      ),
    );
  }
}
