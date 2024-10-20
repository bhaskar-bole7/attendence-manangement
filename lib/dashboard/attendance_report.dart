import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceReport extends StatelessWidget {
  final ValueNotifier<List<Map<String, dynamic>>> studentsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  AttendanceReport({super.key}) {
    fetchStudents(); // Fetch students in the constructor
  }

  // Function to fetch students from Firestore
  Future<void> fetchStudents() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot snapshot = await _firestore.collection('classes').doc('class-8').get();

      if (snapshot.exists) {
        List<dynamic> studentRefs = snapshot['students']; // Fetching student references
        List<Map<String, dynamic>> studentList = [];

        // Fetching each student's data
        for (var ref in studentRefs) {
          DocumentSnapshot userDoc = await ref.get();
          if (userDoc.exists) {
            studentList.add({
              'name': userDoc['name'] ?? 'Unknown',
              'isPresent': false, // Default to not present
            });
          }
        }

        studentsNotifier.value = studentList; // Update the notifier with the student list
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          'Student Attendance',
          style: TextStyle(
            color: Color(0xFF081A52),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.orangeAccent],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'List of Students in a Class',
                  style: TextStyle(
                    color: Color(0xFF081A52),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: studentsNotifier,
                  builder: (context, studentList, _) {
                    return ListView.builder(
                      itemCount: studentList.length,
                      itemBuilder: (context, int index) {
                        return Card(
                          margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: ListTile(
                            leading: Text(
                              '${index + 1}', // Display serial number
                              style: const TextStyle(
                                color: Color(0xFF081A52),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: Text(
                              studentList[index]['name'],
                              style: const TextStyle(
                                  color: Color(0xFF081A52),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Present',
                                  style: TextStyle(
                                      color: Color(0xFF081A52),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Checkbox(
                                  value: studentList[index]['isPresent'],
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      studentsNotifier.value = List.from(studentList)
                                        ..[index]['isPresent'] = value; // Update present status
                                    }
                                  },
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Absent',
                                  style: TextStyle(
                                      color: Color(0xFF081A52),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Checkbox(
                                  value: !studentList[index]['isPresent'], // Inverse of the present status
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      studentsNotifier.value = List.from(studentList)
                                        ..[index]['isPresent'] = !value; // Update absent status
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
