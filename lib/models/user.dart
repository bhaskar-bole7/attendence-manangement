import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String role; // student/teacher

  User({
    required this.id,
    required this.name,
    required this.role,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'],
      role: data['role'],
    );
  }
}
