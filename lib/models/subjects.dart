import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;

  Subject({required this.name, required this.id});

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Subject(name: data['name'], id: doc.id);
  }
}
