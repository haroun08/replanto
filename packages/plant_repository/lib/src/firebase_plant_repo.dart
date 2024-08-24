import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../plant_repository.dart';

class FirebasePlantRepo implements PlantRepo {
  final plantCollection = FirebaseFirestore.instance.collection('plants');

  @override
  Future<List<Plant>> getPlants() async {
    try {
      final querySnapshot = await plantCollection.get();

      return querySnapshot.docs.map((doc) {
        return Plant.fromEntity(PlantEntity.fromDocument(doc.data()));
      }).toList();

    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }



  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
