
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
    return MyUserEntity(
      userId: doc['userId'],
      email: doc['email'],
      name: doc['name'],
      age: doc['age'],
      picture: doc['picture'],
      plants: List<Map<String, dynamic>>.from(doc['plants'] ?? []).map((plantDoc) => PlantEntity.fromDocument(plantDoc)).toList(),
    );
  }
}
