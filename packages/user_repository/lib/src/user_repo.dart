import 'package:plant_repository/plant_repository.dart';

import 'models/models.dart';

abstract class UserRepository {
  Stream<MyUser?> get user;

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser user);

  Future<void> signIn(String email, String password);

  Future<void> logOut();

  Future<void> addPlantToUser(String userId, Plant plant);

  Future<void> deletePlantFromUser(String userId, String plantId) ;

  Future<void> updateProfileData(String userId, Map<String, dynamic> newUserData);

  Future<void> deleteUserAndPlants(String userId);
}