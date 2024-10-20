import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MonthlyAttendanceTable extends StatelessWidget {
  final String classId;
  final String subjectId;
  final int year;

  MonthlyAttendanceTable(
      {required this.classId, required this.subjectId, required this.year});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, int>>>(
      future: getAttendanceForAllMonths(classId, subjectId, year),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No attendance data available.');
        }

        // Data to be displayed in the table
        Map<String, Map<String, int>> attendanceData = snapshot.data!;

        // Generate month headers (columns)
        List<String> months = List.generate(12, (index) {
          return "${year}${(index + 1).toString().padLeft(2, '0')}"; // YYYYMM format
        });

        // Build the DataTable rows
        List<DataRow> rows = attendanceData.entries.map((entry) {
          String studentId = entry.key;
          Map<String, int> studentAttendance = entry.value;

          // Create cells for each month
          List<DataCell> cells = [
            DataCell(Text(studentId)), // Student ID column
          ];

          // Add attendance data for each month
          cells.addAll(months.map((month) {
            int presentCount = studentAttendance[month] ??
                0; // Attendance count for that month
            return DataCell(Text(presentCount.toString()));
          }).toList());

          return DataRow(cells: cells);
        }).toList();

        // Generate the full DataTable
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(
                  label: Text('Student ID')), // First column for student ID
              ...months.map((month) => DataColumn(
                  label: Text(month.substring(4)))), // Columns for each month
            ],
            rows: rows,
          ),
        );
      },
    );
  }

  Future<Map<String, Map<String, int>>> getAttendanceForAllMonths(
      String classId, String subjectId, int year) async {
    final attendanceCollection =
        FirebaseFirestore.instance.collection('attendance');

    // Query for all attendance records in the specified class and subject for the entire year
    QuerySnapshot querySnapshot = await attendanceCollection
        .where('class', isEqualTo: classId)
        .where('subject', isEqualTo: subjectId)
        .get();

    // Initialize a map to store attendance counts by student and month
    Map<String, Map<String, int>> attendanceMap = {};

    // Iterate over the query results and populate the map
    for (var doc in querySnapshot.docs) {
      String studentId = doc['student'];
      int monthlyDate = doc['monthlyDate'];
      bool isPresent = doc['present'];

      // Extract the month as YYYYMM format
      String month = monthlyDate.toString();

      // Initialize student entry if not present
      if (!attendanceMap.containsKey(studentId)) {
        attendanceMap[studentId] = {};
      }

      // Count attendance only if the student was present
      if (isPresent) {
        attendanceMap[studentId]![month] =
            (attendanceMap[studentId]![month] ?? 0) + 1;
      }
    }

    return attendanceMap; // Map of studentId -> (Map of month -> present count)
  }
}
