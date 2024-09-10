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
      final plantDoc = plantsCollection.doc(plantId);
      final plantSnapshot = await plantDoc.get();

      if (plantSnapshot.exists) {
        final plantData = plantSnapshot.data() as Map<String, dynamic>;
        final userId = plantData['userId'];

        await _deletePlantFromUser(userId, plantId);

        await plantDoc.delete();

        log('Plant deleted successfully from both collection and user list');
      } else {
        throw Exception('Plant not found');
      }
    } catch (e) {
      log('Error deleting plant: $e');
      throw Exception('Failed to delete plant: $e');
    }
  }


  Future<void> _deletePlantFromUser(String userId, String plantId) async {
    try {
      // Retrieve the user document
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();

      // Cast the document data to Map<String, dynamic>
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      // Check if 'plants' field exists and is a list
      List<dynamic> plants = userData?['plants'] ?? [];

      // Find the plant map in the array that matches the plantId
      plants.removeWhere((plant) => plant is Map<String, dynamic> && plant['plantId'] == plantId);

      // Update the user's document with the modified array
      await usersCollection.doc(userId).update({
        'plants': plants,
      });

      log('Successfully removed plant with ID: $plantId from user');
    } catch (e) {
      log('Failed to remove plant from user: $e');
      rethrow;
    }
  }



  @override
  Future<Plant> getPlantById(String plantId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('plants').doc(plantId).get();
      if (doc.exists && doc.data() != null) {
        final plantData = doc.data()!;
        final plantEntity = PlantEntity.fromDocument(plantData);
        return Plant.fromEntity(plantEntity);
      } else {
        throw Exception('Plant not found');
      }
    } catch (e) {
      print('Error fetching plant: $e');
      throw Exception('Failed to fetch plant details');
    }
  }


}