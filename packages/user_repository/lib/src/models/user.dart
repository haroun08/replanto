import '../entites/entities.dart';

class MyUser {
  String userId;
  String email;
  String name;
  int  age;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.age,
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    age: 18,
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      age: age,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
        userId: entity.userId,
        email: entity.email,
        name: entity.name,
        age: entity.age
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $age';
  }
}