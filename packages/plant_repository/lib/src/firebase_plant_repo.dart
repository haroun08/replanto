import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_repository/plant_repository.dart';

class FirebasePlantRepo implements PlantRepo {
  final FirebaseAuth _firebaseAuth;
  final CollectionReference plantsCollection = FirebaseFirestore.instance.collection('plants');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  FirebasePlantRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
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

      log('Plant added successfully');
    } catch (e) {
      log('Failed to add plant: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePlant(String plantId, Map<String, dynamic> updatedFields) async {
    try {
      await plantsCollection.doc(plantId).update(updatedFields);
      log('Plant updated successfully');
    } catch (e) {
      log('Error updating plant: $e');
      throw Exception('Error updating plant: $e');
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

      return querySnapshot.docs.map((doc) {
        final plantEntity = PlantEntity.fromDocument(doc.data() as Map<String, dynamic>);
        return Plant.fromEntity(plantEntity);
      }).toList();
    } catch (e) {
      log('Failed to fetch plants: $e');
      return [];
    }
  }

  @override
  Future<void> deletePlant(String plantId) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }

      final plantDoc = await plantsCollection.doc(plantId).get();
      if (plantDoc.exists && plantDoc['userId'] == user.uid) {
        await _deletePlantFromUser(user.uid, plantId);
        await plantsCollection.doc(plantId).delete();

        log('Plant deleted successfully');
      } else {
        throw Exception('User is not authorized to delete this plant');
      }
    } catch (e) {
      log('Failed to delete plant: $e');
      rethrow;
    }
  }

  Future<void> _deletePlantFromUser(String userId, String plantId) async {
    try {
      await usersCollection.doc(userId).update({
        'plants': FieldValue.arrayRemove([plantId]),
      });
    } catch (e) {
      log('Failed to remove plant from user: $e');
      rethrow;
    }
  }
}
