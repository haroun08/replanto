import 'package:plant_repository/plant_repository.dart';

import '../../user_repository.dart';


class MyUser {
  String userId;
  String email;
  String name;
  int age;
  String picture;
  List<Plant> plants;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.age,
    required this.picture,
    required this.plants,
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    age: 18,
    picture: 'https://static.vecteezy.com/system/resources/previews/002/318/271/original/user-profile-icon-free-vector.jpg',
    plants: [],
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      age: age,
      picture: picture,
      plants: plants.map((plant) => plant.toEntity()).toList(),
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      age: entity.age,
      picture: entity.picture,
      plants: entity.plants.map((e) => Plant.fromEntity(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $age, $picture, ${plants.length} plants';
  }
}
