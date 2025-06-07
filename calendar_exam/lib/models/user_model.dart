import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserModel {
  final int? id;
  final String uid; // за съвместимост, може да е UUID
  final String email;
  final String name;
  final String password;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.uid,
    required this.email,
    required this.name,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'name': name,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static String hashPassword(String rawPassword) {
    final bytes = utf8.encode(rawPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}