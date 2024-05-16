import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserLogin {
  final String email;
  final String name;
  final String nisn;

  UserLogin({required this.email, required this.name, required this.nisn});

  factory UserLogin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserLogin(
      email: data['email'],
      name: data['name'],
      nisn: data['nisn'],
    );
  }

  factory UserLogin.fromRawJson(String str) =>
      UserLogin.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
        email: json["email"] ?? '',
        name: json["name"] ?? '',
        nisn: json["nisn"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "nisn": nisn,
      };
}
