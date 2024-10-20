import 'package:attendence_app/models/subjects.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Class {
  final String id;
  final String name;
  final String teacher;
  final List<Subject> subjects; // List of subject names or IDs
  final List<String> studentIds; // List of student references (IDs)

  Class({
    required this.id,
    required this.name,
    required this.teacher,
    required this.subjects,
    required this.studentIds,
  });

  static fromFirestore(DocumentSnapshot doc) async {
    List<DocumentReference> studentsRefs =
        List<DocumentReference>.from(doc['students']);
    List<DocumentReference> subjectsRefs =
        List<DocumentReference>.from(doc['subjects']);
    DocumentReference teacherRef = doc['teacher'];
    List<String> studentIDs = studentsRefs.map((ref) => ref.id).toList();
    List<Subject> subjectList = await fetchSubjects(subjectsRefs);
    String teacherID = teacherRef.id;

    return Class(
        id: doc.id,
        name: doc['name'],
        teacher: teacherID,
        subjects: subjectList,
        studentIds: studentIDs);
  }

  static Future<List<Subject>> fetchSubjects(
      List<DocumentReference> subjectsRefs) async {
    return Future.wait(subjectsRefs.map((subjectRef) async {
      DocumentSnapshot subjectDoc = await subjectRef.get();
      return Subject.fromFirestore(subjectDoc);
    }).toList());
  }
}
