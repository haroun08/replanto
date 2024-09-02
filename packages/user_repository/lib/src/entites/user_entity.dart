
import 'dart:developer';

import 'package:plant_repository/plant_repository.dart';

class MyUserEntity {
  String userId;
  String email;
  String name;
  int age;
  String picture;
  List<PlantEntity> plants;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.age,
    required this.picture,
    required this.plants,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'age': age,
      'picture': picture,
      'plants': plants.map((plant) => plant.toDocument()).toList(),
    };
  }
  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    try {
      final userId = doc['userId'] ?? '';
      final email = doc['email'] ?? '';
      final name = doc['name'] ?? '';
      final age = doc['age'] ?? 0;
      final picture = doc['picture'] ?? '';
      final plants = (doc['plants'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((plantDoc) {
        try {
          return PlantEntity.fromDocument(plantDoc);
        } catch (e) {
          log('Error creating PlantEntity from document: $e');
          rethrow;
        }
      })
          .toList();

      return MyUserEntity(
        userId: userId,
        email: email,
        name: name,
        age: age,
        picture: picture,
        plants: plants,
      );
    } catch (e) {
      log('Error creating MyUserEntity from document: $e');
      rethrow;
    }
  }

}
