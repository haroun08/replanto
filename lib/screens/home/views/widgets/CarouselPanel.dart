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
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4), // changes position of shadow
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                    child: pictureUrl != null
                        ? Image.network(
                      pictureUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.local_florist, size: 150, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
