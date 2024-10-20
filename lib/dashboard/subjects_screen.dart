import 'package:flutter/material.dart';
import '../models/class.dart';
import 'attendance.dart';


class SubjectsScreen extends StatelessWidget {
  final Class classData;

  SubjectsScreen({required this.classData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          'Subjects for ${classData.id}',
          style: TextStyle(
              color: Color(0xFF081A52),
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.builder(
        itemCount: classData.subjects.length,
        itemBuilder: (context, index) {
          // Correctly access the Subject properties
          var subject = classData.subjects[index];
          return Card(
            margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
            color: Color(0xFF748BEA),
            child: ListTile(
              leading: Icon(
                Icons.class_,
                color: Color(0xFF081A52),
              ),
              title: Text(
                subject.name, // Use the name property
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF081A52)),
              ),
              onTap: () {
                // Navigate to StudentsScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentsScreen(
                        classData: classData, subjectId: subject.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
