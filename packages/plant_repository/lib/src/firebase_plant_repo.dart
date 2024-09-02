import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_repository/plant_repository.dart';

class FirebasePlantRepo implements PlantRepo {
  final FirebaseAuth _firebaseAuth;
  final plantsCollection = FirebaseFirestore.instance.collection('plants');
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebasePlantRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> addPlant(Plant plant) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }

      await plantsCollection.doc(plant.plantId).set(plant.toEntity().toDocument());

      await usersCollection.doc(user.uid).update({
        'plants': FieldValue.arrayUnion([plant.plantId]),
      });
    } catch (e) {
      log('Failed to add plant: $e');
      rethrow;
    }
  }

  @override
  Future<List<Plant>> getPlants() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return [];
      }

      final querySnapshot = await plantsCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => Plant.fromEntity(PlantEntity.fromDocument(doc.data())))
          .toList();
    } catch (e) {
      log('Failed to fetch plants: $e');
      return [];
    }
  }
}
