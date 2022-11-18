import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String nickName;
  DateTime birthday;

  User(
      {this.id = '',
      required this.name,
      required this.nickName,
      required this.birthday});

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      nickName: json['nickname'],
      birthday: (json['birthday'] as Timestamp).toDate(),
    );
  }
}
