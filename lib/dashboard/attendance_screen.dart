import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendence_app/models/class.dart';
import 'subjects_screen.dart';

class AttendanceScreen extends StatelessWidget {
  final String userId; // Assuming the teacher is logged in

  AttendanceScreen({required this.userId});

  // Fetch the classes for the teacher from Firestore
  //to fetch a list of classes from a Firestore database and return them as a list of Class objects.
  Future<List<Class>> fetchClassesForTeacher() async {
    var classesSnapshot =
        await FirebaseFirestore.instance.collection('classes').get();

    // Mapping Firestore data to Class model

    List<Class> classList = await Future.wait(classesSnapshot.docs
        .map((doc) async => await Class.fromFirestore(doc)));

    return classList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          'Attendance Screen',
          style: TextStyle(
            color: Color(0xFF081A52),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<List<Class>>(
        future: fetchClassesForTeacher(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No classes found'));
          } else {
            var classes = snapshot.data!;
            return ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                var classData = classes[index];
                return Card(
                  margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                  color: Color(0xFF748BEA),
                  child: ListTile(
                    leading: Icon(
                      Icons.class_,
                      color: Color(0xFF081A52),
                    ),
                    title: Text(
                      '${classData.name}', // Assuming Class model has a 'name' field
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF081A52),
                      ),
                    ),
                    onTap: () {
                      // Navigate to SubjectScreen with the class data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubjectsScreen(classData: classData),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
