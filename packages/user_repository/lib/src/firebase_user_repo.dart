import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/src/entites/entities.dart';
import 'package:user_repository/src/models/user.dart';
import 'package:user_repository/src/user_repo.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebasePlantRepo _plantRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
    required FirebasePlantRepo plantRepo,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _plantRepo = plantRepo;

  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(MyUser.empty);
      } else {
        return usersCollection.doc(firebaseUser.uid).snapshots().map((snapshot) {
          if (snapshot.exists) {
            return MyUser.fromEntity(MyUserEntity.fromDocument(snapshot.data() as Map<String, dynamic>));
          } else {
            return MyUser.empty;
          }
        }).handleError((e) {
          log('Error fetching user details: $e');
          return MyUser.empty;
        });
      }
    });
  }


  @override
  Future<void> updateProfileData(String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myUser.email,
          password: password
      );

      myUser.userId = user.user!.uid;
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> addPlantToUser(String userId, Plant plant) async {
    try {
      // Ensure plant belongs to the user
      if (plant.userId != userId) {
        throw Exception('The plant does not belong to the user.');
      }

      await _plantRepo.addPlant(plant);
    } catch (e) {
      log('Failed to add plant to user: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePlantFromUser(String userId, String plantId) async {
    try {
      final plantDoc = await _plantRepo.plantsCollection.doc(plantId).get();
      if (plantDoc.exists && plantDoc['userId'] == userId) {
        await _plantRepo.deletePlant(plantId);
      } else {
        throw Exception('The plant does not belong to the user or does not exist.');
      }
    } catch (e) {
      log('Failed to delete plant from user: $e');
      rethrow;
    }
  }
}
