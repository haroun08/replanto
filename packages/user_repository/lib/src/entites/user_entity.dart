class MyUserEntity {
  String userId;
  String email;
  String name;
  int age;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.age,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'age': age,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'],
      email: doc['email'],
      name: doc['name'],
      age: doc['age'],
    );
  }
}