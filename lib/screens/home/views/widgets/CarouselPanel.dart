import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:user_repository/user_repository.dart';
import '../details_screen.dart';

class CarouselPanel extends StatelessWidget {
  final List<QueryDocumentSnapshot> plantDocuments;
  final MyUser currentUser;
  final FirebasePlantRepo plantRepo;
  final FirebaseUserRepo userRepo;

  const CarouselPanel({
    Key? key,
    required this.plantDocuments,
    required this.currentUser,
    required this.plantRepo,
    required this.userRepo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StackedCardCarousel(
        items: plantDocuments.map((plantData) {
          final data = plantData.data() as Map<String, dynamic>;

          final name = data['name'] ?? 'Unknown Plant';
          final pictureUrl = data['picture'];
          final plant = Plant(
            plantId: plantData.id,
            name: name,
            picture: pictureUrl ?? '',
            description: data['description'] ?? 'No description available.',
            humidity: data['humidity'] ?? 0,
            pHLevel: data['pHLevel'] ?? 0,
            sunExposure: data['sunExposure'] ?? 0,
            temperature: data['temperature'] ?? 0,
            soilMoisture: data['soilMoisture'] ?? 0,
            healthy: data['healthy'] ?? 0,
            userId: data['userId'],
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(
                    plant: plant,
                    user: currentUser,
                    plantRepo: plantRepo,
                    userRepository: userRepo,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                    child: pictureUrl != null && pictureUrl.isNotEmpty
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
