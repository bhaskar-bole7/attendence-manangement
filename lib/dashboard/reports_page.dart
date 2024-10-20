import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'periodic_attendance_report.dart';

class ReportsPage extends StatefulWidget {
  ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? classChoose;
  String? subjectChoose;

  // List to hold the fetched classes and subjects
  Map<String, String> classList = {};
  Map<String, String> subjectList = {};

  // Store selected class and corresponding subjects
  Map<String, Map<String, String>> classSubjectsMap = {};

  @override
  void initState() {
    super.initState();
    fetchClassesAndSubjects(); // Fetch data from Firestore
  }

  // Method to fetch classes and subjects from Firestore
  Future<void> fetchClassesAndSubjects() async {
    try {
      // Get the 'classes' collection from Firestore
      CollectionReference classesCollection =
      FirebaseFirestore.instance.collection('classes');

      QuerySnapshot querySnapshot = await classesCollection.get();

      // Clear the lists before adding data
      classList.clear();
      classSubjectsMap.clear();

      for (var doc in querySnapshot.docs) {
        String classId = doc.id;
        String className = doc['name'];

        List<DocumentReference> subjectRefs =
        List<DocumentReference>.from(doc['subjects']);

        Map<String, String> subjectMap = {};

        for (var subjectRef in subjectRefs) {
          DocumentSnapshot subjectDoc = await subjectRef.get();
          String subjectId = subjectRef.id;
          String subjectName = subjectDoc['name'];

          subjectMap[subjectId] = subjectName;
        }

        classSubjectsMap[classId] = subjectMap;
        classList[classId] = className;
      }

      setState(() {});
    } catch (e) {
      print("Error fetching classes and subjects: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Attendance Report Screen',
          style: TextStyle(
              color: Color(0xFF081A52), fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 15,),
            const Text(
              'Reports for a list of classes and subjects',
              style: TextStyle(
                  color: Color(0xFF081A52),
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown for Class selection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding inside the box
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white54,
                  ),
                  child: DropdownButton<String>(
                    hint: const Text(
                      'Select class',
                      style: TextStyle(
                          color: Color(0xFF081A52),
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    value: classChoose,
                    items: classList.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value, style: const TextStyle(
                            color: Color(0xFF081A52),
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                        )),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        classChoose = newValue;
                        subjectList = classSubjectsMap[newValue!] ?? {};
                        subjectChoose = null; // Reset subject when class changes
                      });
                    },
                  ),
                ),
                const SizedBox(width: 25),
                // Dropdown for Subject selection (based on selected class)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding inside the box
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white54,
                  ),
                  child: DropdownButton<String>(
                    hint: const Text(
                      'Select subject',
                      style: TextStyle(
                          color: Color(0xFF081A52),
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    value: subjectChoose,
                    items: subjectList.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value, style: const TextStyle(
                            color: Color(0xFF081A52),
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                        )),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        subjectChoose = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (classChoose != null && subjectChoose != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PeriodicAttendanceReporter(
                          classId: classChoose!, subjectId: subjectChoose),
                    ),
                  );
                } else {
                  // Show error message if class or subject is not selected
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please select both class and subject'),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF081A52)),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 8.0),
                child: Text(
                  'Enter',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
